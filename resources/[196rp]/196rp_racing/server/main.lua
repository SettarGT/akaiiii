local QBCore = exports['qb-core']:GetCoreObject()

local activeRaces = {}

local function Notify(src, msg, type)
    TriggerClientEvent('QBCore:Notify', src, msg, type or 'primary')
end

local function GetTrack(trackId)
    for _, t in ipairs(Config.Tracks) do
        if t.id == trackId then return t end
    end
end

-- ── Yarışa başla (giriş haqqı) ──
RegisterNetEvent('196rp_racing:server:start', function(trackId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local track = GetTrack(trackId)
    if not track then return end
    if activeRaces[src] then
        Notify(src, 'Artıq yarışdasınız! Əvvəl bitirin.', 'error')
        return
    end
    if (Player.PlayerData.money.cash or 0) < track.entryFee then
        Notify(src, ('Giriş haqqı ₣%d — kifayət qədər pul yoxdur.'):format(track.entryFee), 'error')
        return
    end
    Player.Functions.RemoveMoney('cash', track.entryFee, 'racing-entry')
    activeRaces[src] = { track = track.id, startTime = os.time() }
    TriggerClientEvent('196rp_racing:client:startRace', src, track)
end)

-- ── Yarış bitişi ──
RegisterNetEvent('196rp_racing:server:finish', function(trackId, timeMs)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local track = GetTrack(trackId)
    if not track or not activeRaces[src] then return end
    timeMs = tonumber(timeMs) or 0
    if timeMs <= 0 or timeMs > 1800000 then return end -- 30 dəqiqədən çox = saxta

    activeRaces[src] = nil
    local name = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname

    MySQL.insert('INSERT INTO 196_race_results (citizenid, name, track_id, time_ms, created_at) VALUES (?, ?, ?, ?, NOW())', {
        Player.PlayerData.citizenid, name, trackId, math.floor(timeMs),
    }, function()
        Notify(src, ('🏁 Yarış bitdi: %s — vaxt: %s'):format(track.label, fmtTime(timeMs)), 'success')
    end)
end)

function fmtTime(ms)
    local m = math.floor(ms / 60000)
    local s = math.floor((ms % 60000) / 1000)
    local c = math.floor((ms % 1000) / 10)
    return ('%d:%02d.%02d'):format(m, s, c)
end

-- ── Liqa: mövsüm balları ──
local function ComputeStandings(cb)
    MySQL.query('SELECT * FROM 196_race_results ORDER BY time_ms ASC', {}, function(rows)
        rows = rows or {}
        local best = {}  -- track -> cid -> ms
        for _, r in ipairs(rows) do
            best[r.track_id] = best[r.track_id] or {}
            if not best[r.track_id][r.citizenid] or r.time_ms < best[r.track_id][r.citizenid] then
                best[r.track_id][r.citizenid] = r.time_ms
            end
        end

        local names = {}
        for _, r in ipairs(rows) do
            names[r.citizenid] = r.name
        end

        local totals = {}  -- cid -> points
        for _, trackId in ipairs({ 'city', 'vine', 'highway' }) do
            local perTrack = best[trackId]
            if perTrack then
                local arr = {}
                for cid, ms in pairs(perTrack) do
                    arr[#arr + 1] = { cid = cid, ms = ms }
                end
                table.sort(arr, function(a, b) return a.ms < b.ms end)
                for i, e in ipairs(arr) do
                    local pts = Config.Points[i]
                    if pts then
                        totals[e.cid] = (totals[e.cid] or 0) + pts
                    end
                end
            end
        end

        local list = {}
        for cid, pts in pairs(totals) do
            list[#list + 1] = { cid = cid, name = names[cid] or cid, points = pts }
        end
        table.sort(list, function(a, b) return a.points > b.points end)
        cb(list)
    end)
end

-- ── Liqa aç ──
RegisterNetEvent('196rp_racing:server:openLeague', function()
    local src = source
    ComputeStandings(function(list)
        TriggerClientEvent('196rp_racing:client:league', src, list)
    end)
end)

-- ── Polis əmri: mövsümü sıfırla (admin) ──
RegisterCommand('liqasifirla', function(source)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player or not IsPlayerAceAllowed(src, 'command') then
        if src > 0 then Notify(src, 'Admin deyilsiniz!', 'error') end
        return
    end
    MySQL.query('TRUNCATE TABLE 196_race_results', {}, function()
        if src > 0 then Notify(src, '✅ Liqa mövsümü sıfırlandı.', 'success') end
        print('[196RP] Liqa mövsümü sıfırlandı')
    end)
end, false)

-- ── Mükafat (admin): yer üzrə pul ──
RegisterCommand('liqamukafat', function(source, args)
    local src = source
    if not IsPlayerAceAllowed(src, 'command') then
        if src > 0 then Notify(src, 'Admin deyilsiniz!', 'error') end
        return
    end
    local place = tonumber(args[1])
    local amount = tonumber(args[2]) or 0
    if not place or place < 1 then return end
    ComputeStandings(function(list)
        local winner = list[place]
        if not winner then return end
        -- Onlayn oyunçunu tap və mükafatlandır
        for _, p in ipairs(QBCore.Functions.GetPlayers()) do
            local P = QBCore.Functions.GetPlayer(p)
            if P and P.PlayerData.citizenid == winner.cid then
                P.Functions.AddMoney('cash', amount, 'league-prize')
                if src > 0 then Notify(src, ('✅ %d-ci yer mükafatı: %s → ₣%d'):format(place, winner.name, amount), 'success') end
                return
            end
        end
        if src > 0 then Notify(src, 'Mükafat alan oyunçu onlayn deyil!', 'error') end
    end)
end, false)
