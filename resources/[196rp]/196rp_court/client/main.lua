local QBCore = exports['qb-core']:GetCoreObject()
local reqId = 0
local pending = {}

local function RPC(action, payload, cb)
    reqId = reqId + 1
    pending[reqId] = cb
    TriggerServerEvent('196rp_court:server:request', reqId, action, payload)
end

RegisterNetEvent('196rp_court:client:response', function(id, data)
    if pending[id] then
        pending[id](data)
        pending[id] = nil
    end
end)

-- ── Qeydləri menyu kimi göstər ──
RegisterNetEvent('196rp_court:client:showRecords', function(records, title)
    local menu = { { header = '⚖️ ' .. title, isMenuHeader = true, icon = 'fas fa-scale-balanced' } }
    if not records or #records == 0 then
        menu[#menu + 1] = { header = 'Qeyd tapılmadı', icon = 'fas fa-check', isDisabled = true }
    else
        local shown = 0
        for _, r in ipairs(records) do
            if shown < 12 then
                local fine = tonumber(r.fine_amount) or 0
                menu[#menu + 1] = {
                    header = ('%s (%s)'):format(r.title or r.type, os.date('%d.%m.%Y %H:%M', timeToEpoch(r.created_at) or os.time())),
                    txt = string.format('%s%s · %s', fine > 0 and ('₣' .. tostring(fine) .. ' · ') or '', r.details or '', r.officer_name or ''),
                    icon = fine > 0 and 'fas fa-money-bill' or 'fas fa-file-lines',
                    isDisabled = true,
                }
                shown = shown + 1
            end
        end
    end
    exports['qb-menu']:openMenu(menu, function() end)
end)

function timeToEpoch(s)
    if not s then return nil end
    local y, m, d, h, mi = s:match('^(%d+)-(%d+)-(%d+) (%d+):(%d+)')
    if not y then return nil end
    return os.time({ year = tonumber(y), month = tonumber(m), day = tonumber(d), hour = tonumber(h), min = tonumber(mi) })
end

-- ── Məhkəmə menyusu ──
local function OpenCourt()
    local pData = QBCore.Functions.GetPlayerData()
    local menu = {
        { header = '⚖️ 196 Məhkəmə', isMenuHeader = true, icon = 'fas fa-scale-balanced' },
        { header = '📋 Öz qeydiyyat tarixçəm', icon = 'fas fa-file-lines', params = { act = 'my' } },
    }
    if pData.job.name == 'judge' then
        menu[#menu + 1] = { header = '⚖️ Təqsirləndirilən üzrə işə bax', icon = 'fas fa-search', params = { act = 'case' } }
        menu[#menu + 1] = { header = '📜 Qərar əmri', txt = '/qerar <id> <cərimə> <həbs dəq> <səbəb>', icon = 'fas fa-gavel', isDisabled = true }
    elseif pData.job.name == 'lawyer' then
        menu[#menu + 1] = { header = '📜 Müvekkil əmri', txt = '/vekil <id>', icon = 'fas fa-user-tie', isDisabled = true }
    end
    exports['qb-menu']:openMenu(menu, function(selected)
        if not selected or not selected.params then return end
        if selected.params.act == 'my' then
            TriggerServerEvent('196rp_court:server:myRecords')
        elseif selected.params.act == 'case' then
            local result = exports['qb-input']:ShowInput({
                header = 'Təqsirləndirilən FİN (məs. 19612345678)',
                submitText = 'Bax',
                inputs = { { text = 'FİN', name = 'fin', type = 'text' } },
            })
            if result and result.fin then
                RPC('records', { citizenid = result.fin }, function(records)
                    TriggerEvent('196rp_court:client:showRecords', records, ('İş materialları: %s'):format(result.fin))
                end)
            end
        end
    end)
end

CreateThread(function()
    local loc = Config.Location
    local blip = AddBlipForCoord(loc.coords)
    SetBlipSprite(blip, 434)
    SetBlipColour(blip, 25)
    SetBlipScale(blip, 0.9)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(loc.label)
    EndTextCommandSetBlipName(blip)

    exports['qb-target']:AddBoxZone('196court', loc.coords, 4.0, 4.0, {
        name = '196court', heading = loc.heading, debugPoly = false,
        minZ = loc.coords.z - 1, maxZ = loc.coords.z + 4,
    }, { options = { { label = '[E] ' .. loc.label .. ' — Qəbul', icon = 'fas fa-scale-balanced', action = OpenCourt } } })
end)
