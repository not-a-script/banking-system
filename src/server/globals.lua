--[[
    Global Core Functions, to be use for compatibility with other scripts
]]


function GetPlayerData(identifier)
    if not typeMustBe(identifier, "string") then return debug("GetPlayerData: incorrect identifier") end

    return GetDataFromCache(identifier)
end

function HasAccount(identifier)
    if not typeMustBe(identifier, "string") then return debug("HasAccount: incorrect identifier") end
    
    local data = GetPlayerData(identifier)
    if not data then return end 

    return data.personalAccount
end

function GetCommonAccounts(identifier)
    if not typeMustBe(identifier, "string") then return debug("GetCommonAccounts: incorrect identifier") end
    
    local data = GetPlayerData(identifier)
    if not data then return end 

    return data.commonAccounts or {}
end

function GetCommonAccountById(identifier, id)
    if not typeMustBe(identifier, "string")  then return debug("GetCommonAccountById: incorrect identifier") end
    if not typeMustBe(id, "number") then return debug("GetCommonAccountById: incorrect id") end
    
    local data = GetPlayerData(identifier)
    if not data then return end 

    return data.commonAccounts[id]
end

function CanCreateCommonAccount(identifier)
    if not identifier then return debug("CanCreateCommonAccount: incorrect identifier") end
    
    return (HasAccount(identifier) and 1 or 0) + #GetCommonAccounts(identifier) < 3
end

function RemoveMoney(identifier, amount, serviceID, callback, force)
    if not typeMustBe(identifier, "string") then return debug("RemoveMoney: incorrect identifier") end
    if not typeMustBe(amount, "number") then return debug("RemoveMoney: incorrect amount") end
    if not typeMustBe(serviceID, "number") then return debug("RemoveMoney: incorrect serviceID") end

    local account = HasAccount(identifier)

    if not force and (amount > account.balance or amount < 0) then  
        debug("RemoveMoney: account not found or doesn't have the money")

        if callback then
            return callback()
        end

        return false
    end

    if not account then return end

    MySQL.Sync.execute("UPDATE stl_bank_accounts SET balance = @balance WHERE owner = @owner AND type = 0", 
        {["@balance"] = account.balance - amount, ["@owner"] = identifier}
    )

    CreateTransaction(identifier, 0, amount, (serviceID and serviceID or 0), account.id, true)

    local PLAYER = GetPlayerData(identifier)
    PLAYER.personalAccount.balance = PLAYER.personalAccount.balance - amount
    AddOrUpdateCache(identifier, PLAYER)

    if callback then 
        return callback(true) 
    end

    return PLAYER
end

function AddMoney(xPlayer, amount, serviceID, callback, force)
    if not typeMustBe(xPlayer, "table") then return debug("AddMoney: incorrect xPlayer") end
    if not typeMustBe(amount, "number") then return debug("AddMoney: incorrect amount") end
    if not typeMustBe(serviceID, "number") then return debug("AddMoney: incorrect serviceID") end

    local account = HasAccount(xPlayer.getIdentifier())

    if not force and (amount > xPlayer.getMoney() or amount < 0) then  
        debug("AddMoney: account not found or doesn't have the money")
        
        if callback then
            return callback()
        end

        return false
    end

    if not account then return end

    MySQL.Sync.execute("UPDATE stl_bank_accounts SET balance = @balance WHERE owner = @owner AND type = 0", 
        { ["@balance"] = account.balance + amount, ["@owner"] = xPlayer.getIdentifier(), }
    )

    CreateTransaction(xPlayer.getIdentifier(), 1, amount, (serviceID and serviceID or 0), account.id, true)

    local PLAYER = GetPlayerData(xPlayer.getIdentifier())
    PLAYER.personalAccount.balance = PLAYER.personalAccount.balance + amount
    AddOrUpdateCache(xPlayer.getIdentifier(), PLAYER)

    if callback then 
        return callback(true) 
    end

    return PLAYER
end

function GetBankMoney(identifier)
    if not typeMustBe(identifier, "string") then return debug("GetBankMoney: incorrect identifier") end

    local account = HasAccount(identifier)

    if not account then 
        debug("GetBankMoney: account not found") 
        return 0
    end

    return account.balance
end


function CreateTransaction(identifier, action, amount, serviceID, accountID, personalAccount)
    if not typeMustBe(identifier, "string") then return debug("CreateTransaction: incorrect identifier") end
    if not typeMustBe(action, "number") then return debug("CreateTransaction: incorrect action") end
    if not typeMustBe(amount, "number") then return debug("CreateTransaction: incorrect amount") end
    if not typeMustBe(serviceID, "number") then return debug("CreateTransaction: incorrect serviceID") end
    if not typeMustBe(accountID, "number") then return debug("CreateTransaction: incorrect accountID") end
     
    local currentDate = os.date('%Y-%m-%d %H:%M:%S', os.time())

    MySQL.Sync.execute("INSERT INTO stl_bank_transfers (owner, action, amount, date, service_id, account_id) VALUES (@owner, @action, @amount, @currentDate, @serviceID, @accountID)",
        {
            ["@owner"] = identifier,
            ["@action"] = action,
            ["@amount"] = amount,
            ["@currentDate"] = currentDate,
            ["@serviceID"] = serviceID,
            ["@accountID"] = accountID,
        }
    )

    local PLAYER = GetPlayerData(identifier)
    if not PLAYER then return end

    if personalAccount then
        table.insert(PLAYER.personalAccount.transfers, 1, {
            action = action,
            amount = amount,
            date = currentDate,
            serviceID = serviceID
        })

        AddOrUpdateCache(identifier, PLAYER)
    else
        -- TODO: When a transaction is made on common account, sync with all connected players who are members
        --[[PLAYER.commonAccounts.transfers[#PLAYER.commonAccounts.transfers] = {
            ownerName = ,
            action = action,
            amount = amount,
            date = currentDate,
            service_id = serviceID
        }]]

        local cache = GetCache()

        for cacheIdentifier, v in pairs(cache) do
            for commonaccountID, account in pairs(v.commonAccounts) do
                if commonaccountID == accountID then
                    local TARGET = v

                    table.insert(TARGET.commonAccounts[accountID].transfers, 1, {
                        ownerName = ("%s %s"):format(PLAYER.firstname, PLAYER.lastname),
                        action = action,
                        amount = amount,
                        date = currentDate,
                        serviceID = serviceID
                    })

                    AddOrUpdateCache(cacheIdentifier, TARGET)
                end
            end
        end
    end
end