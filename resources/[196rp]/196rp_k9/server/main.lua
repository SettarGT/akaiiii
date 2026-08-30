local QBCore = exports['qb-core']:GetCoreObject()

local lastSearch = {}

local function IsPolice(src)
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return false end
    return Player.PlayerData.job.type == 'leo'
end

-- ── İt çağır ──
RegisterCommand('k9', function(source)
    local src = source
    if not IsPolice(src) then
        TriggerClientEvent('QBCore:Notify', src, 'K9 yalnız polis üçündür!', 'error')
        return
    end
    TriggerClientEvent('196rp_k9:client:toggle', src)
end, false)

-- ── İylə (axtarış) ──
RegisterCommand('k9axtar', function(source)
    local src = source
    if not IsPolice(src) then
        TriggerClientEvent('QBCore:Notify', src, 'Bu əmr polis üçündür!', 'error')
        return
    end
    local now = os.time()
    if lastSearch[src] and (now - lastSearch[src]) < Config.Search.Cooldown then
        TriggerClientEvent('QBCore:Notify', src, ('İt dincəlir — %d saniyə gözləyin.'):format(Config.Search.Cooldown - (now - lastSearch[src])), 'error')
        return
    end
    lastSearch[src] = now

    -- Yaxındakı oyunçuların çantasını yoxla
    local officer = QBCore.Functions.GetPlayer(src)
    local officerPos = GetEntityCoords(GetPlayerPed(src))
    local hits = {}
    for _, p in ipairs(QBCore.Functions.GetPlayers()) do
        if p ~= src then
            local Player = QBCore.Functions.GetPlayer(p)
            if Player then
                local pos = GetEntityCoords(GetPlayerPed(p))
                if #(pos - officerPos) <= Config.Search.Radius then
                    for _, item in ipairs(Config.IllegalItems) do
                        local found = Player.Functions.GetItemByName(item)
                        if found and found.amount > 0 then
                            hits[#hits + 1] = {
                                name = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname,
                                item = found.label or item,
                                amount = found.amount,
                            }
                            break
                        end
                    end
                end
            end
        end
    end

    if #hits > 0 then
        local lines = {}
        for _, h in ipairs(hits) do
            lines[#lines + 1] = ('%s — %s x%d'):format(h.name, h.item, h.amount)
        end
        TriggerClientEvent('QBCore:Notify', src, '🐕 İt siqnal verdi! ' .. table.concat(lines, ' | '), 'error')
    else
        TriggerClientEvent('QBCore:Notify', src, '🐕 İt heç nə tapmadı. Bölgə təmizdir.', 'success')
    end
end, false)
