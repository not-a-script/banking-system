--[[
    Initialization
]]




--[[
    Setup caching
]]

--[[
    Data Cache Structure

    {
        ["steam:identifier"] = {
            firstname = string,
            lastname = string,
            personalAccount = {
                id = number,
                password = string,
                balance = number,
                transfers = {
                    {
                        action = number,
                        amount = number,
                        date = timestamp,
                        serviceID = number
                    }
                }
            },
            commonAccounts = {
                [id] = {
                    owner = string,
                    ownerName = string,
                    balance = number,
                    transfers = {
                        {
                            ownerName = string,
                            action = number,
                            amount = number,
                            date = timestamp,
                            serviceID = number
                        }
                    },
                    members = {
                        { identifier = string, name = string }
                    }
                }
            }
        }
    }
]]

local function initialize()
    local cache = {}
    local playersDisconnected = {}

    function AddOrUpdateCache(identifier, data)
        -- AddOrUpdateCache(identifier, [url], data, [key])
        debug("add cache")

        if cache[identifier]  then
            debug("update data already in cache")
        end

        cache[identifier] = data
    end

    function RemoveFromCache(identifier)
        if not cache[identifier] then return end

        cache[identifier] = nil
    end

    function GetDataFromCache(identifier)
        debug("GetDataFromCache: call")

        local playerCache = cache[identifier]
        if not playerCache then return end

        playerCache.identifier = identifier

        return playerCache
    end

    function GetCache()
        return cache
    end

    AddEventHandler("playerDropped", function ()
        local source = source
        if playersDisconnected[source] then return end

        local xPlayer = ESX.GetPlayerFromId(source)
        if not typeMustBe(xPlayer, "table") then return debug("playerDropped: xPlayer not found") end

        playersDisconnected[#playersDisconnected + 1] = { source = source, identifier = xPlayer.getIdentifier() }
    end)

    -- every 6 hours check who disconnected from the server and remove them from cache
    --[[Citizen.CreateThread(function ()
        local interval = 6 * 60 * 60 * 1000

        while true do
            Citizen.Wait(interval)

            local xPlayers = ESX.GetPlayers()

            for i = 1, #playersDisconnected do
                if not xPlayers[playersDisconnected[i].source] then
                    
                    RemoveFromCache(playersDisconnected[i].identifier)
                    playersDisconnected[i] = nil
                end 
            end
        end
    end)]]

    --RegisterCommand("clearcash", function (_, args)
    --    if not args[1] then return end
    --
    --    RemoveFromCache(args[1])
    --end, true)

    --[[
        Player cache creator
    ]]


    local function createPlayer(firstname, lastname)
        local PLAYER = {
            firstname = firstname,
            lastname = lastname,
        }

        return PLAYER
    end

    local function createPlayerCacheIdentity(identifier)
        local identityResult = MySQL.Sync.fetchAll("SELECT firstname, lastname FROM users WHERE identifier = @identifier",
            { ["@identifier"] = identifier }
        )[1]
        local accountResult = MySQL.Sync.fetchAll("SELECT * FROM stl_bank_accounts WHERE owner = @owner AND type = 0",
            { ["@owner"] = identifier }
        )[1]
        local commonAccountsResult = MySQL.Sync.fetchAll([[
            SELECT 
                accounts.id,
                accounts.owner,
                accounts.type,
                accounts.balance,
                accounts.members,
                accounts.password,
                users.firstname,
                users.lastname
            FROM 
                stl_bank_accounts 
            AS 
                accounts 
            INNER JOIN
                users 
            ON 
                accounts.owner = users.identifier 
            WHERE 
                (owner = @owner OR members LIKE @members) 
            AND 
                accounts.type = 1
        ]], 
        { ["@owner"] = identifier, ["@members"] = "%" .. identifier .. "%" }
        )
        local date = os.time() - (Config.lastTransactionDays * 60 * 60 * 24)

        local transfersResult = MySQL.Sync.fetchAll([[
            SELECT 
                transfers.id,
                transfers.owner,
                transfers.action,
                transfers.amount,
                transfers.date,
                transfers.service_id,
                transfers.account_id,
                users.firstname,
                users.lastname
            FROM 
                stl_bank_transfers 
            AS 
                transfers
            INNER JOIN
                users
            ON 
                transfers.owner = users.identifier
            WHERE 
                owner = @owner
            AND 
            date >= @thedate
            ORDER BY 
                date 
            DESC 
            LIMIT 200 
        ]], 
        {  ["@owner"] = identifier, ["@thedate"] = os.date("%Y-%m-%d", date) }
        )

        local PLAYER = createPlayer(identityResult.firstname, identityResult.lastname)

        if accountResult then
            PLAYER.personalAccount = {
                id = accountResult.id,
                password = accountResult.password,
                balance = accountResult.balance,
                transfers = {}
            }
        end

        if commonAccountsResult[1] then
            PLAYER.commonAccounts = {}

            for i = 1, #commonAccountsResult do
                PLAYER.commonAccounts[commonAccountsResult[i].id] = {
                    owner = commonAccountsResult[i].owner,
                    ownerName = ("%s %s"):format(commonAccountsResult[i].firstname, commonAccountsResult[i].lastname),
                    balance = commonAccountsResult[i].balance,
                    transfers = {},
                    members = json.decode(commonAccountsResult[i].members)
                }
            end
        end

        if transfersResult[1] then
            for i = 1, #transfersResult do
                local transfer = {
                    action = transfersResult[i].action,
                    amount = transfersResult[i].amount,
                    date = transfersResult[i].date,
                    serviceID = transfersResult[i].service_id
                }

                -- add transfers to personal account
                if PLAYER.personalAccount and transfersResult[i].account_id == PLAYER.personalAccount.id then
                    PLAYER.personalAccount.transfers[#PLAYER.personalAccount.transfers + 1] = transfer
                    -- add transfers to common account
                else
                    PLAYER.commonAccounts = PLAYER.commonAccounts or {}
                    local commonAccount = PLAYER.commonAccounts[transfersResult[i].account_id]

                    if commonAccount then
                        transfer.ownerName = ("%s %s"):format(transfersResult[i].firstname, transfersResult[i].lastname)

                        PLAYER.commonAccounts[transfersResult[i].account_id].transfers[#commonAccount.transfers + 1] = transfer
                    end
                end
            end
        end

        AddOrUpdateCache(identifier, PLAYER)
    end

    RegisterNetEvent('esx:playerLoaded')
    AddEventHandler('esx:playerLoaded', function(_, playerData)
        local identifier = playerData.getIdentifier()

        if GetDataFromCache(identifier) then
            return debug("playerLoaded: cache found")
        end

        debug("create player cache identity")
        createPlayerCacheIdentity(identifier)
    end)

    if Config.debugMode then
        AddEventHandler("onResourceStart", function (resource)
            if GetCurrentResourceName() ~= resource then return end

            local xPlayers = ESX.GetPlayers()

            for i = 1, #xPlayers do
                createPlayerCacheIdentity(xPlayers[i].getIdentifier())
            end
        end)
    end
end

Citizen.CreateThread(function()
    while not ESX do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end

    initialize()
end)

-- TODO: delete les transactions très anciennes (faire une var config)2
