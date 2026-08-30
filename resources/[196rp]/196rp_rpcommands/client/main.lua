local QBCore = exports['qb-core']:GetCoreObject()
local vip = false

RegisterNetEvent('196rp_vip:client:sync', function(data)
    vip = data and data.vip or false
end)

local function GetRPName()
    local name = GetPlayerName(PlayerId())
    if GetResourceState('196rp_streamer') == 'started' and exports['196rp_streamer']:Enabled() then
        name = exports['196rp_streamer']:Name()
    end
    if vip then
        name = '★ ' .. name
    end
    return name
end

local function SendChatMessage(msg, color)
    TriggerServerEvent('196rp_rpcommands:chatMessage', msg, color or { 147, 196, 255 })
end

RegisterCommand('try', function(_, args)
    local text = table.concat(args, ' ')
    if text == '' then
        QBCore.Functions.Notify(Config.Text.wrong_usage:gsub('%%{cmd}', '/try'), 'error')
        return
    end
    local playerName = GetRPName()
    if math.random() <= Config.TryChance then
        SendChatMessage(Config.Text.try_success:gsub('%%{name}', playerName):gsub('%%{text}', text), { 65, 200, 120 })
    else
        SendChatMessage(Config.Text.try_fail:gsub('%%{name}', playerName):gsub('%%{text}', text), { 220, 80, 80 })
    end
end, false)

-- /do — mühit təsviri (3D mətn olaraq göstərilir)
RegisterCommand('do', function(_, args)
    local text = table.concat(args, ' ')
    if text == '' then
        QBCore.Functions.Notify(Config.Text.wrong_usage:gsub('%%{cmd}', '/do'), 'error')
        return
    end
    TriggerServerEvent('196rp_rpcommands:doMessage', text)
end, false)

-- /ame — anlaşılmayan / pərakəndə hərəkət
RegisterCommand('ame', function(_, args)
    local text = table.concat(args, ' ')
    if text == '' then
        QBCore.Functions.Notify(Config.Text.wrong_usage:gsub('%%{cmd}', '/ame'), 'error')
        return
    end
    local playerName = GetRPName()
    SendChatMessage(Config.Text.ame_prefix:gsub('%%{name}', playerName):gsub('%%{text}', text), { 180, 180, 180 })
end, false)

RegisterKeyMapping('try', 'RP /try istifadə et', 'keyboard', '')
RegisterKeyMapping('do', 'RP /do istifadə et', 'keyboard', '')
RegisterKeyMapping('ame', 'RP /ame istifadə et', 'keyboard', '')

-- /geyim — qarderob (geyim hissələrini fərdi çıxar/dəyiş)
RegisterCommand('geyim', function()
    TriggerEvent('qb-clothing:client:openMenu')
end, false)
