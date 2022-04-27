--[[
    Initialization
]]




    -- Added by Space
    -- Create Blips
    if Config.showBlips then
        for _, position in pairs(Config.blips)do
            local blip = AddBlipForCoord(position)
            SetBlipSprite(blip, 431)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, 0.9)
            SetBlipColour(blip, 2)
            SetBlipAsShortRange(blip, true)

            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString("Los Santos National Bank")
            EndTextCommandSetBlipName(blip)
        end
    end
end)


--[[
    Global Core Functions and useful variables
]]


local shouldDrawInput, guiOpen

function SetGuiOpen(state)
    guiOpen = state
    
    SetNuiFocus(state, state)
end

function IsGuiOpen()
    return guiOpen
end

if Config.debugMode then
    -- avoid active focus on reload
    SetGuiOpen(false)
end


--[[
    Core
]]


-- Check player's distance
Citizen.CreateThread(function ()
    while true do
        Citizen.Wait(300)

        local playerCoords = GetEntityCoords(PlayerPedId())
        local found = false

        for i = 1, #Config.waypoints do
            local distance = #(playerCoords - Config.waypoints[i])

            if distance < Config.useDistance then
                if not found then
                    found = true
                end
            end
        end

        if found then 
            shouldDrawInput = true
        elseif shouldDrawInput then
            shouldDrawInput = false
        end
    end
end)

-- Draw text and check if the gui still has to be open
Citizen.CreateThread(function ()
    while true do
        Citizen.Wait(5)

        if IsGuiOpen() then
            local playerPed = PlayerPedId()

            if IsEntityDead(playerPed) then
                SetGuiOpen(false)

                SendNUIMessage(
                    {
                        action = "close"
                    }
                )
            end

            DisableControlAction(0, 1, true) -- LookLeftRight
            DisableControlAction(0, 2, true) -- LookUpDown
            DisablePlayerFiring(playerPed, true) -- Disable weapon firing
            DisableControlAction(0, 142, true) -- MeleeAttackAlternate
            DisableControlAction(0, 106, true) -- VehicleMouseControlOverride
        elseif shouldDrawInput then
            SetTextComponentFormat("STRING")
            AddTextComponentString("Press ~INPUT_CONTEXT~ to open the menu.")
            DisplayHelpTextFromStringLabel(0, 0, 1, -1)

            if IsControlJustReleased(1, Config.controlOpenMenu) then
                SetGuiOpen(true)

                ESX.TriggerServerCallback("stl_bankingsystem:triggerAction", function(playerData)
                    SendNUIMessage(
                        {
                            action = "open",
                            data = playerData
                        }
                    )
                end, "getPlayerData")
            end
        end
    end
end)
