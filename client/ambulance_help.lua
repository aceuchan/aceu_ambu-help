local QBCore = exports['qb-core']:GetCoreObject()

-- Help
local helpAllowed = false -- Default state: /help is disabled if EMS are online

RegisterNetEvent("aceu_emscommand:updateHelpStatus", function(status)
    helpAllowed = status
end)

RegisterCommand("help", function()
    local player = PlayerPedId()
    local isDead = QBCore.Functions.GetPlayerData().metadata["isdead"] -- More reliable check

    QBCore.Functions.TriggerCallback("aceu_emscommand:checkEMS", function(emsOnline)
        if emsOnline and not helpAllowed then
            TriggerEvent('QBCore:Notify', "EMS are on duty, request help from them!", "error")
            return
        end

        if isDead then
            DoScreenFadeOut(1000) -- Fade to black over 1 second
            Wait(1000) -- Wait for the fade to complete
            TriggerServerEvent("aceu_emscommand:help") -- Request unstuck from server
        else
            TriggerEvent('QBCore:Notify', "You can only use this command while dead.", "error")
        end
    end)
end, false)

RegisterNetEvent("aceu_emscommand:teleport", function(coords)
    local player = PlayerPedId()
    SetEntityCoords(player, coords.x, coords.y, coords.z, false, false, false, false)
    SetEntityHeading(player, coords.w)
    
    Wait(500) -- Small delay before fade-in
    DoScreenFadeIn(1000) -- Fade the screen back in over 1 second
    
    TriggerEvent('QBCore:Notify', "You passed out and the local doctor brought you here!", "success")
end)
