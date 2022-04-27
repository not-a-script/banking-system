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
            return ESX.ShowNotification("Il n'y a pas ~r~assez d'argent~w~ dans le compte.", false, false, 140) 
        end

        callback(json.encode(actionData))
        ESX.ShowNotification(("Vous avez ~g~retiré~w~ %s$."):format(data.amount), false, false, 140)
    end, "removeMoney", { amount = data.amount, accountType = data.accountType, serviceID = 1, accountID = data.accountID })
end)

RegisterNUICallback("addMoney", function(data, callback)
    print(data.accountID)
    ESX.TriggerServerCallback("stl_bankingsystem:triggerAction", function(actionData)
        if not actionData then
            return ESX.ShowNotification("Vous n'avez pas ~r~assez d'argent~w~ sur vous.", false, false, 140)
            --ESX.ShowNotification("Vous n'avez pas ~r~assez d'argent~w~ sur vous.", false, false, 140)
        end

        callback(json.encode(actionData))
        ESX.ShowNotification(("Vous avez ~g~déposé~w~ %s$."):format(data.amount), false, false, 140)
    end, "addMoney", { amount = data.amount, accountType = data.accountType, serviceID = 1, accountID = data.accountID })
end)

RegisterNUICallback("transferMoney", function(data, callback)
    data.target = json.decode(data.target)

    ESX.TriggerServerCallback("stl_bankingsystem:triggerAction", function(actionData)
        if not actionData then
            return ESX.ShowNotification("Il n'y a pas ~r~assez d'argent~w~ dans le compte.", false, false, 140)
        end

        callback(json.encode(actionData))
        ESX.ShowNotification(("Vous avez ~g~transféré~w~ %s$ à ~o~%s."):format(data.amount, data.target.name), false, false, 140)
    end, "transferMoney", { amount = data.amount, target = data.target.source, accountType = data.accountType, accountID = data.accountID })
end)

RegisterNUICallback("addPlayerToAccount", function (accountData, callback)
    accountData.target = json.decode(accountData.target)

    ESX.TriggerServerCallback('stl_bankingsystem:triggerAction', function(data)
        if data.memberAlreadyTaken then
            return ESX.ShowNotification("Ce joueur possède ~r~déjà 3 comptes~w~ communs", false, false, 140)
        end

        ESX.ShowNotification(("Vous venez ~g~d'ajouter ~w~le joueur ~o~%s"):format(accountData.target.name), false, false, 140)
        callback(json.encode({
            success = true, 
            targetIdentifier = data.targetIdentifier
        }))
    end, "addPlayerToAccount", { target = accountData.target, accountID = accountData.accountID })
end)

RegisterNUICallback("removeCommonUser", function (data, callback)
    ESX.TriggerServerCallback('stl_bankingsystem:triggerAction', function(success)
        if not success then 
            return ESX.ShowNotification("~r~Impossible de retirer l'utilisateur", false, false, 140)
        end

        ESX.ShowNotification(("Vous venez de ~g~retirer ~w~ le joueur ~o~%s"):format(data.member.name), false, false, 140)
        callback(true)
    end, "removeCommonUser", { target = data.member, accountID = data.accountID })
end)

RegisterNUICallback("deleteCommonAccount", function (data, callback)
    ESX.TriggerServerCallback("stl_bankingsystem:triggerAction", function(success) 
        if not success then
            return ESX.ShowNotification("~r~Un problème est survenue lors de la suppression du compte", false, false, 140)
        end

        callback(true)
    end, "deleteCommonAccount", { accountID = data.accountID })
end)