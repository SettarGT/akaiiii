local QBCore = exports['qb-core']:GetCoreObject()

local function OpenJobMenu()
    local pData = QBCore.Functions.GetPlayerData()
    local menu = {
        { header = Config.Text.header, isMenuHeader = true, icon = 'fas fa-briefcase' },
        { header = Config.Text.current_job:gsub('%%{job}', pData.job.label or 'Mülki şəxs'), isMenuHeader = false, icon = 'fas fa-user-tie' },
    }
    for jobName, desc in pairs(Config.Jobs) do
        menu[#menu + 1] = {
            header = (QBCore.Shared.Jobs[jobName] and QBCore.Shared.Jobs[jobName].label) or jobName,
            txt = desc,
            icon = 'fas fa-arrow-right',
            params = { job = jobName },
        }
    end
    menu[#menu + 1] = {
        header = Config.Text.quit_job,
        txt = Config.Text.quit_desc,
        icon = 'fas fa-door-open',
        params = { quit = true },
    }
    exports['qb-menu']:openMenu(menu, function(selected)
        if not selected then return end
        if selected.params and selected.params.quit then
            TriggerServerEvent('196rp_jobs:quit')
        elseif selected.params and selected.params.job then
            TriggerServerEvent('196rp_jobs:apply', selected.params.job)
        end
    end)
end

CreateThread(function()
    for i, loc in ipairs(Config.Locations) do
        exports['qb-target']:AddBoxZone('196jobs_' .. i, loc.coords, 2.0, 2.0, {
            name = '196jobs_' .. i,
            heading = loc.heading,
            debugPoly = false,
            minZ = loc.coords.z - 1,
            maxZ = loc.coords.z + 3,
        }, {
            options = {
                {
                    label = '[E] ' .. loc.label,
                    icon = 'fa-solid fa-briefcase',
                    action = function()
                        OpenJobMenu()
                    end,
                },
            },
            distance = 2.5,
        })
    end
end)
