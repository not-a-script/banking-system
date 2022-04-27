--[[
    Core Functions
]]

    
    ESX.RegisterServerCallback('stl_bankingsystem:getMoney', function(source, callback)
        local xPlayer = ESX.GetPlayerFromId(source)
        if not xPlayer then return end

        callback(GetBankMoney(xPlayer.getIdentifier()))
    end)

    local Functions = {
        ["getPlayerData"] = function(xPlayer, data, source)
            local onlinePlayers = {}
    
            for _, player in ipairs(GetPlayers()) do
                local object = { 
                    name =  GetPlayerName(player), 
                    source = player
                }

                if player == tostring(source) then
                    object.isCurrentUser = true
                end
    
                onlinePlayers[#onlinePlayers + 1] = object
            end
    
            return { playerData = GetPlayerData(xPlayer.getIdentifier()), onlinePlayers = onlinePlayers }
        end,
        ["registerAccount"] = function (xPlayer, data)
            -- TODO: cleaning code to be done here
            -- personal account
            if data.accountType == 0 then
                if HasAccount(xPlayer.getIdentifier()) then return debug("registerAccount: account already exist") end
    
                local accountID = MySQL.Sync.insert("INSERT INTO stl_bank_accounts (owner, type, balance, members, password) VALUES (@owner, 0, @balance, NULL, @password)",
                    {
                        ["@owner"] = xPlayer.getIdentifier(),
                        ["@balance"] = Config.startPersonalAccountMoney,
                        ["@password"] = data.password
                    } 
                )
    
                if not accountID then return debug("registerAccount: accountID not found") end
    
                local PLAYER = GetPlayerData(xPlayer.getIdentifier())
    
                PLAYER.personalAccount = {
                    id = accountID,
                    password = data.password,
                    balance = Config.startPersonalAccountMoney,
                    transfers = {}
                }
    
                AddOrUpdateCache(xPlayer.getIdentifier(), PLAYER)
    
                return { playerData = PLAYER }
            -- common account
            elseif data.accountType == 1 then
                local sqlMembers = {}
    
                for _, v in pairs(data.members) do
                    v = json.decode(v)
    
                    local xTarget =  ESX.GetPlayerFromId(v.source)
                    if not xTarget then return end
    
                    if not CanCreateCommonAccount(xTarget.getIdentifier()) then 
                        return {
                            memberAlreadyTaken = true 
                        } 
                    end
    
                    sqlMembers[#sqlMembers + 1] = {
                        identifier = xTarget.getIdentifier(),
                        name = xTarget.getName()
                    }
                end
    
                local accountID = MySQL.Sync.insert("INSERT INTO stl_bank_accounts (owner, type, balance, members, password) VALUES (@owner, 1, 0, @members, NULL)",
                    {
                        ["@owner"] = xPlayer.getIdentifier(),
                        ["@members"] = json.encode(sqlMembers),
                    }
                )
    
                if not accountID then return debug("Register Common Account: accountID not found") end
    
                local PLAYER = GetPlayerData(xPlayer.getIdentifier())
                PLAYER.commonAccounts = PLAYER.commonAccounts or {} 
                PLAYER.commonAccounts[accountID] = {
                    owner = xPlayer.getIdentifier(),
                    ownerName = ("%s %s"):format(PLAYER.firstname, PLAYER.lastname),
                    balance = 0,
                    transfers = {},
                    members = sqlMembers
                }
    
                AddOrUpdateCache(xPlayer.getIdentifier(), PLAYER)
    
                return { playerData = PLAYER, currentCommonID = accountID }
            end
        end,
        ["loginPersonalAccount"] = function (xPlayer, data)
            local account = HasAccount(xPlayer.getIdentifier())
            if not account then return debug("registerAccount: account doesn't exist") end
            
            return account.password == data.password 
        end,
        ["addPlayerToAccount"] = function (xPlayer, data)
            local xTarget = ESX.GetPlayerFromId(data.target.source)
            if not xTarget then return end
    
            -- verify that the player has a free common account
            if not CanCreateCommonAccount(xTarget.getIdentifier()) then 
                return cb({
                    memberAlreadyTaken = true 
                }) 
            end
    
            local commonAccounts = GetCommonAccounts(xPlayer.getIdentifier())
            if not commonAccounts[data.accountID] then return debug("addPlayerToAccount: account doesn't have the given id") end
    
            -- TODO: some work to be done here
            local members = commonAccounts[data.accountID].members
    
            members[#members + 1] = {
                identifier = xTarget.getIdentifier(),
                name = xTarget.getName()
            }
    
            local PLAYER = GetPlayerData(xPlayer.getIdentifier())
            PLAYER.commonAccounts[data.accountID].members = members
            AddOrUpdateCache(xPlayer.getIdentifier(), PLAYER)

            local TARGET = GetPlayerData(xTarget.getIdentifier())
            TARGET.commonAccounts = TARGET.commonAccounts or {}
            TARGET.commonAccounts[data.accountID] = PLAYER.commonAccounts[data.accountID]
            AddOrUpdateCache(xTarget.getIdentifier(), TARGET)
            
            MySQL.Sync.execute("UPDATE stl_bank_accounts SET members = @members WHERE owner = @owner AND type = 1 AND id = @accountID", 
                {
                    ["@members"] = json.encode(members),
                    ["@owner"] = xPlayer.getIdentifier(),
                    ["@accountID"] = data.accountID
                })
    
            return {
                memberAlreadyTaken = false,
                targetIdentifier = xTarget.getIdentifier()
            }
        end,
        ["removeMoney"] = function (xPlayer, data)
            -- TODO: remove money en fonction du type de compte: personnel ou commun
            -- personnal account
            if data.accountType == 0 then
                local account = HasAccount(xPlayer.getIdentifier())
                if not account then return debug("removeMoney: account not found") end
                
                local PLAYER = RemoveMoney(xPlayer.getIdentifier(), data.amount, data.serviceID)
        
                if PLAYER then
                    xPlayer.addMoney(data.amount)
                end
    
                return PLAYER
            -- common account
            elseif data.accountType == 1 then
                local commonAccount = GetCommonAccountById(xPlayer.getIdentifier(), data.accountID)
            
                if not commonAccount then
                    debug("removeCommonMoney: account not found")
                    return false
                end
    
                if data.amount > commonAccount.balance or data.amount < 0 then
                    return false
                end

				-- avoid removing money at same time wich  create conflicts
                local result = MySQL.Sync.fetchAll("SELECT balance WHERE id = @accountID AND type = 1",
                    {["@accountID"] = data.accountID}
                )

                if not result[1] then return false end

                if result[1].balance < data.amount then
                    return false
                end
            
                MySQL.Sync.execute("UPDATE stl_bank_accounts SET balance = @balance WHERE id = @accountID AND type = 1", 
                    { 
                        ["@balance"] = commonAccount.balance - data.amount,
                        ["@accountID"] = data.accountID,
                    }
                )
    
                xPlayer.addMoney(data.amount)
                
                local PLAYER = GetPlayerData(xPlayer.getIdentifier())
                PLAYER.commonAccounts[data.accountID].balance = commonAccount.balance - data.amount
                AddOrUpdateCache(xPlayer.getIdentifier(), PLAYER)
        
                CreateTransaction(xPlayer.getIdentifier(), 0, data.amount, (data.serviceID and data.serviceID or 1), data.accountID)
            
                return PLAYER
            end
        end,
        ["addMoney"] = function (xPlayer, data)
            -- personnal account
            if data.accountType == 0 then
                local account = HasAccount(xPlayer.getIdentifier())
                if not account then return debug("addMoney: account not found") end
    
                local PLAYER = AddMoney(xPlayer, data.amount, data.serviceID)
    
                if PLAYER then
                    xPlayer.removeMoney(data.amount)
                end
    
                return PLAYER
            -- common account
            elseif data.accountType == 1 then
                local commonAccount = GetCommonAccountById(xPlayer.getIdentifier(), data.accountID)
                
                if not commonAccount then
                    debug("addCommonMoney: account not found")
                    return false
                end
    
                if data.amount > xPlayer.getMoney() or data.amount < 0 then
                    return false
                end
    
                MySQL.Sync.execute("UPDATE stl_bank_accounts SET balance = @balance WHERE id = @accountID AND type = 1", 
                    { 
                        ["@balance"] = commonAccount.balance + data.amount,
                        ["@accountID"] = data.accountID
                    }
                )
                
                xPlayer.removeMoney(data.amount)
                
                local PLAYER = GetPlayerData(xPlayer.getIdentifier())
                PLAYER.commonAccounts[data.accountID].balance = commonAccount.balance + data.amount
                AddOrUpdateCache(xPlayer.getIdentifier(), PLAYER)
    
                CreateTransaction(xPlayer.getIdentifier(), 1,data.amount, (data.serviceID and data.serviceID or 0), data.accountID)
    
                return PLAYER
            end
        end,
        ["transferMoney"] = function (xPlayer, data)
            -- personal account
            if data.accountType == 0 then
                local xTarget = ESX.GetPlayerFromId(data.target)
                if not xTarget then return end
            
                local account = HasAccount(xPlayer.getIdentifier())
                if not account then return debug("transferMoney: account not found") end
    
                if data.amount > account.balance or data.amount < 0 then
                    return false
                end
    
                local targetAccount = HasAccount(xTarget.getIdentifier())
                if not targetAccount then return debug("transferMoney: targetAccount not found") end
                
                local PLAYER = GetPlayerData(xPlayer.getIdentifier())
                PLAYER.personalAccount.balance = PLAYER.personalAccount.balance - data.amount
                AddOrUpdateCache(xPlayer.getIdentifier(), PLAYER)
    
                local TARGET = GetPlayerData(xTarget.getIdentifier())
                TARGET.personalAccount.balance = TARGET.personalAccount.balance + data.amount
                AddOrUpdateCache(xTarget.getIdentifier(), TARGET)
    
                MySQL.Sync.execute("UPDATE stl_bank_accounts SET balance = @balance WHERE owner = @owner AND type = 0",
                    {["@balance"] = account.balance - data.amount, ["@owner"] = xPlayer.getIdentifier()}
                )
    
                CreateTransaction(xPlayer.getIdentifier(), 0, data.amount, 1, account.id, true)
    
                MySQL.Sync.execute("UPDATE stl_bank_accounts SET balance = @balance WHERE owner = @owner AND type = 0", 
                    {["@balance"] = targetAccount.balance + data.amount, ["@owner"] = xTarget.getIdentifier()}
                )
    
                CreateTransaction(xTarget.getIdentifier(), 1, data.amount, 1, targetAccount.id, true)
    
                return PLAYER
            -- common account
            elseif data.accountType == 1 then
                local xTarget = ESX.GetPlayerFromId(data.target)
                if not xTarget then return end
    
                local commonAccount = GetCommonAccountById(xPlayer.getIdentifier(), data.accountID)
            
                if not commonAccount then
                    debug("transferCommonMoney: account not found")
                    return false
                end
    
                if data.amount > commonAccount.balance or data.amount < 0 then
                    return false
                end
    
                local targetAccount = HasAccount(xTarget.getIdentifier())
    
                if not targetAccount then 
                    debug("transferCommonMoney: account not found")
                    return false
                end
                
                MySQL.Sync.execute("UPDATE stl_bank_accounts SET balance = @balance WHERE id = @accountID AND owner = @owner AND type = 1",
                    {["@balance"] = commonAccount.balance - data.amount, ["@accountID"] = data.accountID, ["@owner"] = xPlayer.getIdentifier()}
                )
    
                CreateTransaction(xPlayer.getIdentifier(), 0, data.amount, 1, data.accountID)
                
                MySQL.Sync.execute("UPDATE stl_bank_accounts SET balance = @balance WHERE owner = @owner AND type = 0", 
                    {["@balance"] = targetAccount.balance + data.amount, ["@owner"] = xTarget.getIdentifier()}
                )
                
                CreateTransaction(xTarget.getIdentifier(), 1, data.amount, 1, targetAccount.id, true)
                
                local PLAYER = GetPlayerData(xPlayer.getIdentifier())
                PLAYER.commonAccounts[data.accountID].balance = commonAccount.balance - data.amount
                AddOrUpdateCache(xPlayer.getIdentifier(), PLAYER)
    
                local TARGET = GetPlayerData(xTarget.getIdentifier())
                TARGET.commonAccounts[data.accountID].balance = TARGET.commonAccounts[data.accountID].balance + data.amount
                AddOrUpdateCache(xTarget.getIdentifier(), TARGET)
    
                return PLAYER
            end
        end,
        ["removeCommonUser"] = function (xPlayer, data)
            local commonAccount = GetCommonAccountById(xPlayer.getIdentifier(), data.accountID)
            
            if not commonAccount then
                debug("removeCommonUser: account not found")
                return false
            end
            debug("1")
    
            if commonAccount.owner ~= xPlayer.getIdentifier() then
                debug("removeCommonUser: not owner")
                return false
            end
    
            debug("1")
    
            local found = false
    
            for k, v in pairs(commonAccount.members) do
                if v.identifier == data.target.identifier then
                    found = true
                    table.remove(commonAccount.members, k)
    
                    break
                end
            end
            debug("1")
    
            if not found then
                return false
            end
            debug("1")
    
            MySQL.Sync.execute("UPDATE stl_bank_accounts SET members = @members WHERE owner = @owner AND type = 1 AND id = @accountID", 
                {
                    ["@members"] = json.encode(commonAccount.members),
                    ["@owner"] = xPlayer.getIdentifier(),
                    ["@accountID"] = data.accountID
                }
            )
            debug("1")
    
            local PLAYER = GetPlayerData(xPlayer.getIdentifier())
            PLAYER.commonAccounts[data.accountID].members = commonAccount.members
            AddOrUpdateCache(xPlayer.getIdentifier(), PLAYER)
            debug("1")
    
            return true
        end,
        ["deleteCommonAccount"] = function (xPlayer, data)
            local commonAccount = GetCommonAccountById(xPlayer.getIdentifier(), data.accountID)
            
            if not commonAccount then
                debug("deleteCommonAccount: account not found")
                return false
            end
    
            MySQL.Sync.execute("DELETE FROM stl_bank_accounts WHERE owner = @owner AND type = 1 and id = @accountID",
                {
                    ["@owner"] = xPlayer.getIdentifier(),
                    ["@accountID"] = data.accountID
                }
            )
    
            local PLAYER = GetPlayerData(xPlayer.getIdentifier())
            PLAYER.commonAccounts[data.accountID] = nil
            AddOrUpdateCache(xPlayer.getIdentifier(), PLAYER)
    
            return true
        end
    }
    
    ESX.RegisterServerCallback("stl_bankingsystem:triggerAction", function(source, callback, action, data)
        local xPlayer = ESX.GetPlayerFromId(source)
        if not xPlayer then return debug("triggerAction: ESX Player not found") end
    
        if not typeMustBe(action, "string") then return debug("triggerAction: Action is incorrect") end
        if not typeMustBe(Functions[action], "function") then return debug("triggerAction: Functions is incorrect or not found") end
    
        if data and not typeMustBe(data, "table") then return debug("triggerAction: data must be a table") end
    
        callback(Functions[action](xPlayer, data, source))
    end)
end)
