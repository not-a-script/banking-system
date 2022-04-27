RegisterNUICallback("getConfig", function (_, callback)
    callback(json.encode({
        lastTransactionDays = Config.lastTransactionDays,
        servicesType = Config.servicesType
    }))
end)

RegisterNUICallback('closeMenu', function(data)
    SetGuiOpen(false)
    
    SendNUIMessage(
        {
            action = "close"
        }
    )
end)

RegisterNUICallback("sendNotification", function (data)
    ESX.ShowNotification(data.message, false, false, 140)
end)

RegisterNUICallback("registerAccount", function(data, callback)
    ESX.TriggerServerCallback("stl_bankingsystem:triggerAction", function(actionData) 
        callback(json.encode(actionData))
    end, "registerAccount", { accountType = data.accountType, password = data.password, members = data.members })
end)

RegisterNUICallback("loginPersonalAccount", function(data, callback)
    ESX.TriggerServerCallback("stl_bankingsystem:triggerAction", function(hasAccess) 
        callback(hasAccess)
    end, "loginPersonalAccount", { password = data.password })
end)

RegisterNUICallback("removeMoney", function(data, callback)
    ESX.TriggerServerCallback("stl_bankingsystem:triggerAction", function(actionData)
        if not actionData then
            return ESX.ShowNotification("There is not ~r~enough money~w~ in the account", false, false, 140) 
        end

        callback(json.encode(actionData))
        ESX.ShowNotification(("You have ~g~withdrawn~w~ %s$."):format(data.amount), false, false, 140)
    end, "removeMoney", { amount = data.amount, accountType = data.accountType, serviceID = 1, accountID = data.accountID })
end)

RegisterNUICallback("addMoney", function(data, callback)
    print(data.accountID)
    ESX.TriggerServerCallback("stl_bankingsystem:triggerAction", function(actionData)
        if not actionData then
            return ESX.ShowNotification("You don't have ~r~enough money~w~ on you.", false, false, 140)
        end

        callback(json.encode(actionData))
        ESX.ShowNotification(("You have ~g~deposited~w~ %s$."):format(data.amount), false, false, 140)
    end, "addMoney", { amount = data.amount, accountType = data.accountType, serviceID = 1, accountID = data.accountID })
end)

RegisterNUICallback("transferMoney", function(data, callback)
    data.target = json.decode(data.target)

    ESX.TriggerServerCallback("stl_bankingsystem:triggerAction", function(actionData)
        if not actionData then
            return ESX.ShowNotification("There is not ~r~enough money~w~ in the account.", false, false, 140)
        end

        callback(json.encode(actionData))
        ESX.ShowNotification(("You ~g~transferred~w~ %s$ to ~o~%s."):format(data.amount, data.target.name), false, false, 140)
    end, "transferMoney", { amount = data.amount, target = data.target.source, accountType = data.accountType, accountID = data.accountID })
end)

RegisterNUICallback("addPlayerToAccount", function (accountData, callback)
    accountData.target = json.decode(accountData.target)

    ESX.TriggerServerCallback('stl_bankingsystem:triggerAction', function(data)
        if data.memberAlreadyTaken then
            return ESX.ShowNotification("This player already ~r~has 3 joint~w~ accounts", false, false, 140)
        end

        ESX.ShowNotification(("You have just ~g~added ~w~the player ~o~%s"):format(accountData.target.name), false, false, 140)
        callback(json.encode({
            success = true, 
            targetIdentifier = data.targetIdentifier
        }))
    end, "addPlayerToAccount", { target = accountData.target, accountID = accountData.accountID })
end)

RegisterNUICallback("removeCommonUser", function (data, callback)
    ESX.TriggerServerCallback('stl_bankingsystem:triggerAction', function(success)
        if not success then 
            return ESX.ShowNotification("~r~Unable to remove the user", false, false, 140)
        end

        ESX.ShowNotification(("You have just ~g~removed ~w~ the player ~o~%s"):format(data.member.name), false, false, 140)
        callback(true)
    end, "removeCommonUser", { target = data.member, accountID = data.accountID })
end)

RegisterNUICallback("deleteCommonAccount", function (data, callback)
    ESX.TriggerServerCallback("stl_bankingsystem:triggerAction", function(success) 
        if not success then
            return ESX.ShowNotification("~r~A problem occurred while deleting the account", false, false, 140)
        end

        callback(true)
    end, "deleteCommonAccount", { accountID = data.accountID })
end)