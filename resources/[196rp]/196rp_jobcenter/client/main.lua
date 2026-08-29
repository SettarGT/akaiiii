-- 196 RP | İş elanları lövhəsi — müştəri tərəfi
-- Bələdiyyə və İş Mərkəzindəki lövhələrə yaxınlaşıb E basın.

local blips = {}

CreateThread(function()
    for i = 1, #Config.Boards do
        local board = Config.Boards[i]
        local blip = AddBlipForCoord(board.coords.x, board.coords.y, board.coords.z)
        SetBlipSprite(blip, 498)  -- briefcase blip
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 0.8)
        SetBlipColour(blip, 5)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(board.label)
        EndTextCommandSetBlipName(blip)
        blips[i] = blip
    end
end)

CreateThread(function()
    while true do
        local wait = 750
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local closest = nil
        local closestDist = 999.0

        for i = 1, #Config.Boards do
            local board = Config.Boards[i]
            local dist = #(coords - board.coords)

            if dist < 50.0 then
                wait = 0
                DrawMarker(27, board.coords.x, board.coords.y, board.coords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                    1.0, 1.0, 0.5, 255, 190, 60, 160, false, true, 2, nil, nil, false)
            end

            if dist < 2.0 and dist < closestDist then
                closestDist = dist
                closest = board
            end
        end

        if closest then
            ESX.TextUI(('[E] — ~y~%s~s~'):format(closest.label), 'info')
            if IsControlJustPressed(0, 38) then
                OpenJobBoard()
            end
        else
            ESX.HideUI()
        end

        Wait(wait)
    end
end)

-- İş lövhəsini aç
function OpenJobBoard()
    local xPlayerJob = ESX.PlayerData.job
    local currentJobName = xPlayerJob and xPlayerJob.name or 'unemployed'

    ESX.TriggerServerCallback('196rp_jobcenter:getJobs', function(allJobs)
        -- Menyu qur
        local menu = {}
        menu[#menu + 1] = {
            icon = 'fas fa-user',
            title = ('Cari işiniz: ~y~%s~s~'):format(currentJobName == 'unemployed' and 'İşsiz' or (xPlayerJob.label or currentJobName)),
            unselectable = true,
        }

        -- Bələdiyyə işləri (hər kəs üçün)
        menu[#menu + 1] = {
            icon = 'fas fa-briefcase',
            title = '🏛 Bələdiyyə işləri',
            unselectable = true,
        }
        for i = 1, #Config.MunicipalJobs do
            local job = Config.MunicipalJobs[i]
            menu[#menu + 1] = {
                icon = job.icon,
                title = ('%s %s'):format(job.icon, job.label),
                description = ('%s Maaş: ~g~%s$~s~'):format(job.desc, job.salary),
                name = 'muni_' .. job.name,
            }
        end

        -- Xidmət işləri
        menu[#menu + 1] = {
            icon = 'fas fa-shield-alt',
            title = '🚔 Dövlət xidmətləri',
            unselectable = true,
        }
        for i = 1, #Config.PublicJobs do
            local job = Config.PublicJobs[i]
            menu[#menu + 1] = {
                icon = job.icon,
                title = ('%s %s'):format(job.icon, job.label),
                description = job.desc,
                name = 'svc_' .. job.name,
            }
        end

        -- Digər işlər (bazada olan)
        local otherJobs = {}
        for i = 1, #allJobs do
            local j = allJobs[i]
            if not j.isService and j.name ~= 'unemployed' then
                local isMuni = false
                for k = 1, #Config.MunicipalJobs do
                    if Config.MunicipalJobs[k].name == j.name then
                        isMuni = true
                        break
                    end
                end
                if not isMuni then
                    otherJobs[#otherJobs + 1] = j
                end
            end
        end

        if #otherJobs > 0 then
            menu[#menu + 1] = {
                icon = 'fas fa-building',
                title = '🏢 Digər işlər',
                unselectable = true,
            }
            for i = 1, #otherJobs do
                local j = otherJobs[i]
                menu[#menu + 1] = {
                    icon = 'fas fa-briefcase',
                    title = ('%s %s'):format(j.icon, j.label),
                    description = j.desc,
                    name = 'other_' .. j.name,
                }
            end
        end

        -- İşdən çıxma
        if currentJobName ~= 'unemployed' then
            menu[#menu + 1] = {
                icon = 'fas fa-door-open',
                title = '🚪 İşdən çıx',
                name = 'quit_job',
            }
        end

        exports['esx_context']:Open('right', menu, function(selected)
            if not selected.name then
                return
            end

            -- Bələdiyyə işi
            if selected.name:match('^muni_') then
                local jobName = selected.name:sub(6)
                ESX.TriggerServerCallback('196rp_jobcenter:hireMunicipal', function(success, msg)
                    ESX.ShowNotification(msg, success and 'success' or 'error', 6000)
                end, jobName)
            end

            -- Xidmət işi
            if selected.name:match('^svc_') then
                local jobName = selected.name:sub(5)
                ESX.TriggerServerCallback('196rp_jobcenter:hireService', function(success, msg)
                    ESX.ShowNotification(msg, success and 'success' or 'error', 6000)
                end, jobName)
            end

            -- Digər işlər (yalnız məlumat)
            if selected.name:match('^other_') then
                ESX.ShowNotification('Bu işə başlamaq üçün adminə müraciət edin: /setjob [id] ' .. selected.name:sub(7), 'info', 8000)
            end

            -- İşdən çıxma
            if selected.name == 'quit_job' then
                ESX.TriggerServerCallback('196rp_jobcenter:quitJob', function(success, msg)
                    ESX.ShowNotification(msg, success and 'success' or 'error', 6000)
                end)
            end
        end)
    end)
end
