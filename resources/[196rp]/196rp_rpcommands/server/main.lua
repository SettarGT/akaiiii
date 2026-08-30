local QBCore = exports['qb-core']:GetCoreObject()

local function GetNearbyPlayers(src, radius)
    local ped = GetPlayerPed(src)
    local pCoords = GetEntityCoords(ped)
    local list = {}
    for _, player in ipairs(GetPlayers()) do
        local targetPed = GetPlayerPed(player)
        local tCoords = GetEntityCoords(targetPed)
        if targetPed == ped or #(pCoords - tCoords) <= radius then
            list[#list + 1] = player
        end
    end
    return list
end

local function SendWebhook(content)
    if Config.ReportWebhook == '' or not Config.ReportWebhook then return end
    PerformHttpRequest(Config.ReportWebhook, function(err, text, headers) end, 'POST',
        json.encode({
            username = '196 RP | Report',
            embeds = { {
                title = '🛑 Yeni Report',
                description = content,
                color = 15158332,
                footer = { text = '196 RP' },
                timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ'),
            } }
        }),
        { ['Content-Type'] = 'application/json' })
end

-- Çat mesajı (yalnız yaxınlıqdakılara)
RegisterNetEvent('196rp_rpcommands:chatMessage', function(msg, color)
    local src = source
    for _, player in ipairs(GetNearbyPlayers(src, 15.0)) do
        TriggerClientEvent('chat:addMessage', player, {
            color = color or { 147, 196, 255 },
            multiline = true,
            args = { msg }
        })
    end
end)

-- /do — 3D mətn
RegisterNetEvent('196rp_rpcommands:doMessage', function(msg)
    local src = source
    local name = GetPlayerName(src)
    if GetResourceState('196rp_streamer') == 'started' and exports['196rp_streamer']:IsStreamer(src) then
        name = 'Gizli Şəxs'
    end
    for _, player in ipairs(GetNearbyPlayers(src, 20.0)) do
        TriggerClientEvent('QBCore:Command:ShowMe3D', player, src, ('* %s %s'):format(name, msg))
    end
end)

-- /report — adminlərə bildiriş
QBCore.Commands.Add('report', 'Bir problemi adminlərə bildir', {
    { name = 'message', help = 'Problem təsviri (daha çox söz üçün dırnaq işarələri istifadə edin)' }
}, false, function(source, args)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end

    local fullText = table.concat(args, ' ')
    if fullText == '' then return end
    fullText = fullText:gsub('[~<].-[>~]', ''):sub(1, 250)

    local msg = ('🔴 [REPORT] %s (%d): %s'):format(Player.PlayerData.charinfo.firstname .. ' ' ..
        (Player.PlayerData.charinfo.lastname or ''), source, fullText)

    for _, admin in ipairs(QBCore.Functions.GetPlayers()) do
        if IsPlayerAceAllowed(admin, 'command') then
            TriggerClientEvent('chat:addMessage', admin, {
                color = { 255, 80, 80 },
                multiline = true,
                args = { msg }
            })
            TriggerClientEvent('QBCore:Notify', admin, ('Report: %s'):format(fullText), 'error')
        end
    end

    TriggerClientEvent('chat:addMessage', source, {
        color = { 255, 80, 80 },
        multiline = true,
        args = { ('🟠 Reportınız göndərildi.'):format() }
    })

    SendWebhook(msg)
end, false)

-- /pm — şəxsi mesaj
QBCore.Commands.Add('pm', 'Oyunçuya şəxsi mesaj göndər', {
    { name = 'id', help = 'Oyunçu ID-si' },
    { name = 'message', help = 'Mesaj' }
}, false, function(source, args)
    local target = tonumber(args[1])
    if not target then return end
    local fullText = table.concat(args, ' ', 2):gsub('[~<].-[>~]', '')
    if fullText == '' then return end

    local senderName = GetPlayerName(source)
    if GetResourceState('196rp_streamer') == 'started' and exports['196rp_streamer']:IsStreamer(source) then
        senderName = 'Gizli Şəxs'
    end
    TriggerClientEvent('chat:addMessage', target, {
        color = { 255, 200, 100 },
        multiline = true,
        args = { ('[PM] %s: %s'):format(senderName, fullText) }
    })
    TriggerClientEvent('chat:addMessage', source, {
        color = { 255, 200, 100 },
        multiline = true,
        args = { ('[PM -> %s] %s'):format(target, fullText) }
    })
end, false)

-- ── /license: bütün lisenziyalar ──
QBCore.Commands.Add('license', 'Lisenziyalarınızı göstər', {}, false, function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    local meta = Player.PlayerData.metadata
    local lines = {
        '🪪 LİSENZİYALARINIZ',
        ('📄 Pasport: %s | FİN: %s | Qan: %s'):format(
            Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname,
            meta.fin or '—', meta.bloodtype or '—'),
        ('🚗 Sürücülük: %s'):format(meta.drivinglicense and '✅ var' or '❌ yox'),
        ('🔫 Silah: %s'):format(meta.weaponlicense and '✅ var' or '❌ yox'),
        ('📷 Mətbuat: %s'):format(meta.presslicense and '✅ var' or '❌ yox'),
        ('⚖️ Vəkillik: %s'):format(meta.lawyerlicense and '✅ var' or '❌ yox'),
    }
    TriggerClientEvent('chat:addMessage', source, {
        color = { 247, 183, 51 },
        multiline = true,
        args = { table.concat(lines, '\n') },
    })
end)
