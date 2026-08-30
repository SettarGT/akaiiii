local QBCore = exports['qb-core']:GetCoreObject()

local twatter = {}   -- { id, author, text, likes, time }
local grams = {}
local seq = 0
local likeCD = {}

local function NameOf(src)
    local P = QBCore.Functions.GetPlayer(src)
    if not P then return 'Anonim' end
    local c = P.PlayerData.charinfo
    return (c.firstname or '?') .. ' ' .. (c.lastname or '?')
end

local function Post(app, src, text)
    text = tostring(text or ''):sub(1, Config.Post.max)
    if #text < Config.Post.min then
        TriggerClientEvent('QBCore:Notify', src, ('Mətn %d–%d simvol olmalıdır.'):format(Config.Post.min, Config.Post.max), 'error')
        return
    end
    seq = seq + 1
    local item = {
        id = seq,
        author = NameOf(src),
        text = text,
        likes = 0,
        time = os.time(),
    }
    local feed = app == 'gram' and grams or twatter
    table.insert(feed, 1, item)
    if #feed > Config.MaxPosts then
        feed[#feed] = nil
    end
    TriggerClientEvent('QBCore:Notify', src, app == 'gram' and '📸 196-Gram paylaşıldı!' or '🐦 Twatter paylaşıldı!', 'success')
end

RegisterNetEvent('196rp_social:server:post', function(app, text)
    local src = source
    if app ~= 'twatter' and app ~= 'gram' then return end
    Post(app, src, text)
end)

RegisterNetEvent('196rp_social:server:get', function(app)
    local src = source
    local feed = app == 'gram' and grams or twatter
    TriggerClientEvent('196rp_social:client:feed', src, app, feed)
end)

RegisterNetEvent('196rp_social:server:like', function(app, id)
    local src = source
    local feed = app == 'gram' and grams or twatter
    id = tonumber(id)
    if not feed or not id then return end
    local key = ('%s_%s_%d'):format(src, app, id)
    if likeCD[key] and likeCD[key] > os.time() then return end
    likeCD[key] = os.time() + Config.LikeCD
    for _, p in ipairs(feed) do
        if p.id == id then
            p.likes = (p.likes or 0) + 1
            break
        end
    end
end)
