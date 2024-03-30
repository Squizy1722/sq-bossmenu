local QBCore = exports['qb-core']:GetCoreObject()
        local employees = {}
        local gradesmenu = {}
        local closestplayers = {}

        RegisterNetEvent('sq-bossmenu:server:OpenMenu', function()
          TriggerClientEvent('sq-bossmenu:client:show',source)
          TriggerEvent('sq-bossmenu:server:update', source)
          TriggerEvent('sq-bossmenu:server:updategradesmenu', source)
          TriggerEvent('sq-bossmenu:server:updatehirelist', source)
        end)

     --[[   QBCore.Commands.Add('openboss', 'Open Boss Menu (BOSS Only)', {}, false, function(source)
            TriggerClientEvent('sq-bossmenu:client:show',source)
            TriggerEvent('sq-bossmenu:server:update', source)
            TriggerEvent('sq-bossmenu:server:updategradesmenu', source)
            TriggerEvent('sq-bossmenu:server:updatehirelist', source)
          end)]]

          RegisterNetEvent('sq-bossmenu:server:update', function(src)
            employees = {} -- Reset the employees table
            local players = exports.oxmysql:executeSync("SELECT * FROM `players` WHERE `job` LIKE '%".. QBCore.Functions.GetPlayer(src).PlayerData.job.name .."%'")
            for _, v in pairs(players) do
              local status = 'Offline'
              local onlineplayer = QBCore.Functions.GetPlayerByCitizenId(v.citizenid)
              if onlineplayer then
                status = 'Online'
              end
              local resultImage = exports.oxmysql:executeSync('SELECT * FROM mdt_data WHERE cid = ?', {v.citizenid})
              img = 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/bc/Unknown_person.jpg/925px-Unknown_person.jpg'
              if resultImage[1] then
                img = resultImage[1].pfp
              end

            --  if resultImage[1] then local img = resultImage[1].pfp end
              employees[#employees+1] = {
                  online = status,
                  name = json.decode(v.charinfo).firstname .. ' ' .. json.decode(v.charinfo).lastname,
                  gradename = json.decode(v.job).grade.name,
                  gradelevel = json.decode(v.job).grade.level,
                  cid = v.citizenid,
                  img = img
              }
          end
  
          local PlayerJob = QBCore.Functions.GetPlayer(src).PlayerData.job.name
          local PlayerName = QBCore.Functions.GetPlayer(src).PlayerData.charinfo.firstname .. " " .. QBCore.Functions.GetPlayer(src).PlayerData.charinfo.lastname
          local result = exports.oxmysql:executeSync('SELECT * FROM management_funds WHERE job_name = ?', {PlayerJob})
          local societyamount = tonumber(result[1].amount)
          TriggerClientEvent("sq-bossmenu:client:update",src,employees,societyamount,PlayerName,PlayerJob)
          end)

          RegisterNetEvent('sq-bossmenu:server:addemployee', function(playerid)
            local src = source
            local Me = QBCore.Functions.GetPlayer(src)
            local Player = QBCore.Functions.GetPlayer(tonumber(playerid))
            local gradelevel = 0
            if playerid == nil then return TriggerClientEvent('QBCore:Notify', src, "You must fill all the arguments", 'error') end
            if Player then
              if Player.PlayerData.job.name ~= Me.PlayerData.job.name then
                if gradelevel < Me.PlayerData.job.grade.level then
                  Player.Functions.SetJob(Me.PlayerData.job.name, gradelevel)
                  Player.Functions.SetJob(Me.PlayerData.job.name, gradelevel)
                  TriggerClientEvent('QBCore:Notify', src, "Sucessfulluy got the job!", "success")
                  TriggerClientEvent('QBCore:Notify', playerid, "You have been got " ..Me.PlayerData.job.name.." job", "success")
                Wait(100)
                QBCore.Player.Save(playerid)
                Wait(100)
                TriggerEvent('sq-bossmenu:server:refresh', src)
                TriggerEvent('sq-bossmenu:server:update', src)
                else
                  TriggerClientEvent('QBCore:Notify', src, "You can't give player same grade or higher", 'error')
                end
              else
                TriggerClientEvent('QBCore:Notify', src, 'Player already has '..Me.PlayerData.job.name..' job', 'error')
              end
            else
              TriggerClientEvent('QBCore:Notify', src, 'Did not find player', 'error')
            end
          end)

          RegisterNetEvent('sq-bossmenu:server:fireemployee', function(cid)
            local src = source
            local offlinplayer = exports.oxmysql:executeSync('SELECT * FROM players WHERE citizenid = ? LIMIT 1', { cid })
            local onlineplayer = QBCore.Functions.GetPlayerByCitizenId(cid)
            local Me = QBCore.Functions.GetPlayer(src)
            if onlineplayer then
              if Me.PlayerData.job.name == onlineplayer.PlayerData.job.name then
            if Me.PlayerData.job.grade.level > onlineplayer.PlayerData.job.grade.level then
              if src == onlineplayer.PlayerData.source then return TriggerClientEvent('QBCore:Notify', src, "You can't promote yourself", 'error') end
              onlineplayer.Functions.SetJob('unemployed', 0)
              TriggerClientEvent('QBCore:Notify', src, "Employee fired!", "success")
              TriggerClientEvent('QBCore:Notify', onlineplayer, "You have been got fire", "success")
              Wait(100)
              QBCore.Player.Save(onlineplayer.PlayerData.source)
              Wait(100)
              TriggerEvent('sq-bossmenu:server:update', src)
            else
              TriggerClientEvent('QBCore:Notify', src, "You can't fire player same grade or higher", 'error')
            end
          end
            else
              if offlinplayer[1]~= nil then
                if Me.PlayerData.job.name == json.decode(offlinplayer[1].job).name then
                  if Me.PlayerData.job.grade.level > tonumber(json.decode(offlinplayer[1].job).grade.level) then
                local job = {}
                job.name = "unemployed"
                job.label = "Unemployed"
                job.payment = QBCore.Shared.Jobs[job.name].grades['0'].payment or 500
                job.onduty = true
                job.isboss = false
                job.grade = {}
                job.grade.name = nil
                job.grade.level = 0
                exports.oxmysql:update('UPDATE players SET job = ? WHERE citizenid = ?', { json.encode(job), cid })
                TriggerClientEvent('QBCore:Notify', src, "Employee fired!", "success")
                
                Wait(200)
                TriggerEvent('sq-bossmenu:server:update', src)
                else
                  TriggerClientEvent('QBCore:Notify', src, "You can't fire player same grade or higher", 'error')
                end
                end
              end
            end
          end)

          RegisterNetEvent('sq-bossmenu:server:promoteemployee', function(cid, gradelevel)
            local src = source
            local offlinplayer = exports.oxmysql:executeSync('SELECT * FROM players WHERE citizenid = ? LIMIT 1', { cid })
            local onlineplayer = QBCore.Functions.GetPlayerByCitizenId(cid)
            local Me = QBCore.Functions.GetPlayer(src)
            if tonumber(gradelevel) == nil then return TriggerClientEvent('QBCore:Notify', src, "You must fill all the arguments", 'error') end
            if onlineplayer then
              if Me.PlayerData.job.name == onlineplayer.PlayerData.job.name then
            if Me.PlayerData.job.grade.level > tonumber(gradelevel) then
              if not Me.PlayerData.job.isboss then return TriggerClientEvent('QBCore:Notify', src, "You are not a boss", 'error') end
              if tonumber(gradelevel) == onlineplayer.PlayerData.job.grade.level then return TriggerClientEvent('QBCore:Notify', src, "The player already have this job level", 'error') end
              if src == onlineplayer.PlayerData.source then return TriggerClientEvent('QBCore:Notify', src, "You can't promote yourself", 'error') end
              onlineplayer.Functions.SetJob(Me.PlayerData.job.name, tonumber(gradelevel))
              TriggerClientEvent('QBCore:Notify', src, "Employee promoted!", "success")
              TriggerClientEvent('QBCore:Notify', onlineplayer, "You have been got promot", "success")
              Wait(100)
              QBCore.Player.Save(onlineplayer.PlayerData.source)
              Wait(100)
              TriggerEvent('sq-bossmenu:server:update', src)
            else
              TriggerClientEvent('QBCore:Notify', src, "You can't promote player same grade or higher", 'error')
            end
          end
            else
              if offlinplayer[1]~= nil then
                if Me.PlayerData.job.name == json.decode(offlinplayer[1].job).name then
                  if Me.PlayerData.job.grade.level > tonumber(gradelevel) then
                    if not Me.PlayerData.job.isboss then return TriggerClientEvent('QBCore:Notify', src, "You are not a boss", 'error') end
                    if tonumber(gradelevel) == tonumber(json.decode(offlinplayer[1].job).grade.level) then return TriggerClientEvent('QBCore:Notify', src, "The player already have this job level", 'error') end
                    local thejob = QBCore.Shared.Jobs[Me.PlayerData.job.name]
                    local thegrade = thejob.grades[gradelevel]
                    local thegradename = thegrade.name
                    local thelabelname = thejob.label
                    local theisBoss = thegrade.isboss
                local job = {}
                job.name = Me.PlayerData.job.name
                job.label = thelabelname
                job.payment = QBCore.Shared.Jobs[job.name].grades[gradelevel].payment or 500
                job.onduty = true
                job.isboss = theisBoss
                job.grade = {}
                job.grade.name = thegradename
                job.grade.level = gradelevel
                exports.oxmysql:update('UPDATE players SET job = ? WHERE citizenid = ?', { json.encode(job), cid })
                TriggerClientEvent('QBCore:Notify', src, "Employee promoted!", "success")
                
                Wait(200)
                TriggerEvent('sq-bossmenu:server:update', src)
                else
                  TriggerClientEvent('QBCore:Notify', src, "You can't promote player same grade or higher", 'error')
                end
                end
              end
            end
          end)

          RegisterNetEvent('sq-bossmenu:server:withdraw', function(amount)
            local src = source
            local Me = QBCore.Functions.GetPlayer(src)
            local result = exports.oxmysql:executeSync('SELECT * FROM management_funds WHERE job_name = ?', {Me.PlayerData.job.name})
            if amount == nil then return TriggerClientEvent('QBCore:Notify', src, "You must fill all the arguments", 'error') end
            if result[1].amount >= amount then
            exports.oxmysql:update('UPDATE management_funds SET amount = ? WHERE job_name = ?',{result[1].amount - amount, Me.PlayerData.job.name})
            Me.Functions.AddMoney("cash", amount, "sqbossmenu-withdraw")
            TriggerClientEvent('QBCore:Notify', src, "You have withdraw "..amount..'$', 'success')
            else
              TriggerClientEvent('QBCore:Notify', src, "Society don't have enough money", 'error')
            end
          end)

          RegisterNetEvent('sq-bossmenu:server:deposit', function(amount)
            local src = source
            local Me = QBCore.Functions.GetPlayer(src)
            local result = exports.oxmysql:executeSync('SELECT * FROM management_funds WHERE job_name = ?', {Me.PlayerData.job.name})
            if amount == nil then return TriggerClientEvent('QBCore:Notify', src, "You must fill all the arguments", 'error') end
            if Me.PlayerData.money.cash >= amount then
              exports.oxmysql:update('UPDATE management_funds SET amount = ? WHERE job_name = ?',{result[1].amount + amount, Me.PlayerData.job.name})
              Me.Functions.RemoveMoney("cash", amount, "sqbossmenu-deposit")
              TriggerClientEvent('QBCore:Notify', src, "You have deposit "..amount..'$', 'success')
            else
              TriggerClientEvent('QBCore:Notify', src, "You don't have enough cash on you", 'error')
            end
          end)

          RegisterNetEvent('sq-bossmenu:server:updategradesmenu', function(src)
            gradesmenu = {} -- Reset the employees table
            local Me = QBCore.Functions.GetPlayer(src)
            local thejob = QBCore.Shared.Jobs[Me.PlayerData.job.name]
            for k, v in pairs(thejob.grades) do
              if v.isboss == nil then
                v.isboss = false
              else
                if v.isboss == true then 
                v.isboss = true
                end
              end

              gradesmenu[#gradesmenu+1] = {
                  gradenumber = k,
                  gradename = v.name,
                  isboss = tostring(v.isboss),
                  societyname = Me.PlayerData.job.name
              }
          end
  
          TriggerClientEvent("sq-bossmenu:client:updategradesmenu",src,gradesmenu)
          end)

          RegisterNetEvent('sq-bossmenu:server:updatehirelist', function(src)
            closestplayers = {} -- Reset the employees table
            local players = GetPlayers()
            local Me = QBCore.Functions.GetPlayer(src)
            for _, v in pairs(players) do
              local ClosestPlayer = QBCore.Functions.GetPlayer(v)
              if ClosestPlayer then
              local distance = #(Me.PlayerData.coords - ClosestPlayer.PlayerData.coords)
              if distance <= 10 then
              if Me.PlayerData.job.name == ClosestPlayer.PlayerData.job.name then
              closestplayers[#closestplayers+1] = {
                  name = json.decode(v.charinfo).firstname .. ' ' .. json.decode(v.charinfo).lastname,
                  id = v,
                  cid = v.citizenid
              }
            end
            end
          end
          end
  
          TriggerClientEvent("sq-bossmenu:client:updatehirelist",src,closestplayers)
          end)

          RegisterNetEvent('sq-bossmenu:server:openbossinv', function()
            local Me = QBCore.Functions.GetPlayer(source)
            TriggerClientEvent('sq-bossmenu:client:openbossinv', source, Me.PlayerData.job.name)
          end)

          RegisterNetEvent('sq-bossmenu:server:refresh', function()
            local Me = QBCore.Functions.GetPlayer(source)
            TriggerClientEvent('sq-bossmenu:server:updatehirelist', source)
            TriggerEvent('sq-bossmenu:server:update', source)
          end)