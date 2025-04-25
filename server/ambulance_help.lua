local QBCore = exports['qb-core']:GetCoreObject()
local helpAllowed = false -- Default state: /help is disabled if EMS are online

RegisterNetEvent("aceu_emscommand:updateHelpStatus", function(status)
    helpAllowed = status
end)

RegisterCommand("help", function()
    local player = PlayerPedId()
    local isDead = QBCore.Functions.GetPlayerData().metadata["isdead"] -- Proper way to check death status

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

-- Server-side logic integration
RegisterNetEvent("aceu_emscommand:help", function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if Player then
        local unstuckCoords = vector4(312.68, -580.95, 43.5, 69.97) -- Change this to your desired location
        TriggerClientEvent("aceu_emscommand:teleport", src, unstuckCoords)
    end
end)

RegisterCommand("helptoggle", function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player and (Player.PlayerData.job.name == "ambulance" or Player.PlayerData.job.name == "police") then
        helpAllowed = not helpAllowed
        TriggerClientEvent("aceu_emscommand:updateHelpStatus", -1, helpAllowed) -- Sync with all clients
        TriggerClientEvent('QBCore:Notify', source, "/help is now " .. (helpAllowed and "enabled" or "disabled"), "primary")
    else
        TriggerClientEvent('QBCore:Notify', source, "Only EMS or Police can use this command!", "error")
    end
end, false)
QBCore.Functions.CreateCallback("aceu_emscommand:checkEMS", function(source, cb)
    local emsOnline = false
    for _, v in pairs(QBCore.Functions.GetPlayers()) do
        local Player = QBCore.Functions.GetPlayer(v)
        if Player and Player.PlayerData.job.name == "ambulance" and Player.PlayerData.job.onduty then
            emsOnline = true
            break
        end
    end
    cb(emsOnline)
end)
