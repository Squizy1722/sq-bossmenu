QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = QBCore.Functions.GetPlayerData()
local shownBossMenu = false

local function CloseMenuFull()
    exports[Config.DrawTextExports]:HideText()
    shownBossMenu = false
end

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
end)

RegisterNetEvent("QBCore:Client:OnPlayerUnload", function()
    PlayerData = {}
end)

RegisterNetEvent('QBCore:Player:SetPlayerData', function(val)
    PlayerData = val
end)

RegisterNetEvent('sq-bossmenu:client:show', function(players)
    SetNuiFocus(true, true)
    SendNUIMessage({
        type = 'show',
    })
end)

RegisterNUICallback("hide", function(data)
    SetNuiFocus(false, false)
end)

RegisterNetEvent('sq-bossmenu:client:update', function(employees,societyamount,Pfullname,Pjob)
    local id = GetPlayerServerId(PlayerId())
    SendNUIMessage({
        citizenid = PlayerData.citizenid,
        type = 'update',
        Employees = employees,
        societyamount = societyamount,
        Pfullname = Pfullname,
        Pjob = Pjob,
    })
end)

RegisterNetEvent('sq-bossmenu:client:updatehirelist', function(closestplayers)
    local id = GetPlayerServerId(PlayerId())
    SendNUIMessage({
        citizenid = PlayerData.citizenid,
        type = 'updatehirelist',
        ClosestPlayers = closestplayers,
    })
end)

RegisterNUICallback("addemployee", function(data)
    TriggerServerEvent('sq-bossmenu:server:addemployee',tonumber(data.id))
end)

RegisterNUICallback("fireemployee", function(data)
    TriggerServerEvent('sq-bossmenu:server:fireemployee',data.cid)
end)

RegisterNUICallback("promoteemployee", function(data)
    TriggerServerEvent('sq-bossmenu:server:promoteemployee',data.cid,data.gradelevel)
end)

RegisterNUICallback("openbossinv", function()
    TriggerServerEvent("sq-bossmenu:server:openbossinv")
end)

RegisterNUICallback("refresh", function()
    TriggerServerEvent("sq-bossmenu:server:refresh")
end)


RegisterNetEvent('sq-bossmenu:client:openbossinv', function(jobname)
    TriggerServerEvent("inventory:server:OpenInventory", "stash", "boss_"..jobname, {
        maxweight = 1000000,
        slots = 100,
    })
    TriggerEvent("inventory:client:SetCurrentStash", "boss_"..jobname)
end)

RegisterNetEvent('sq-bossmenu:client:refresh', function()
    local id = GetPlayerServerId(PlayerId())
    SendNUIMessage({
        type = 'refresh',
    })
end)

RegisterNUICallback("withdraw", function(data)
    TriggerServerEvent('sq-bossmenu:server:withdraw',tonumber(data.amount))
end)

RegisterNUICallback("deposit", function(data)
    TriggerServerEvent('sq-bossmenu:server:deposit',tonumber(data.amount))
end)

RegisterNetEvent('sq-bossmenu:client:updategradesmenu', function(Gradesmenu)
    local id = GetPlayerServerId(PlayerId())
    SendNUIMessage({
        type = 'updategradesmenu',
        Gradesmenu = Gradesmenu,
    })
end)

RegisterNetEvent('sq-bossmenu:client:OpenMenu', function()
    TriggerServerEvent('sq-bossmenu:server:OpenMenu')
end)


CreateThread(function()
        while true do
            local wait = 2500
            local pos = GetEntityCoords(PlayerPedId())
            local inRangeBoss = false
            local nearBossmenu = false
            if PlayerData.job then
                wait = 0
                for k, menus in pairs(Config.BossMenus) do
                    for _, coords in ipairs(menus) do
                        if k == PlayerData.job.name and PlayerData.job.isboss then
                            if #(pos - coords) < 5.0 then
                                inRangeBoss = true
                                if #(pos - coords) <= 1.5 then
                                    nearBossmenu = true
                                    if not shownBossMenu then
                                        exports[Config.DrawTextExports]:DrawText('[E] Open Job Management', 'left')
                                        shownBossMenu = true
                                    end
                                    if IsControlJustReleased(0, 38) then
                                        
                                        TriggerEvent('sq-bossmenu:client:OpenMenu')
                                    end
                                end

                                if not nearBossmenu and shownBossMenu then
                                    CloseMenuFull()
                                    shownBossMenu = false
                                end
                            end
                        end
                    end
                end
                if not inRangeBoss then
                    Wait(1500)
                    if shownBossMenu then
                        CloseMenuFull()
                        shownBossMenu = false
                    end
                end
            end
            Wait(wait)
        end
end)