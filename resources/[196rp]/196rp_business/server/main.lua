local QBCore = exports['qb-core']:GetCoreObject()

local function Notify(src, msg, type)
    TriggerClientEvent('QBCore:Notify', src, msg, type or 'primary')
end

local function GetBusiness(id)
    for _, b in ipairs(Config.Businesses) do
        if b.id == id then return b end
    end
    return nil
end

local function DBGet(ids, cb)
    if #ids == 0 then cb({}) return end
    local marks = {}
    for i = 1, #ids do marks[i] = '?' end
    MySQL.query(('SELECT * FROM 196_businesses WHERE id IN (%s)'):format(table.concat(marks, ',')), ids, function(result)
        cb(result or {})
    end)
end

local cache = {}

local function GetCached(bizId, cb)
    if cache[bizId] then cb(cache[bizId]) return end
    MySQL.query('SELECT * FROM 196_businesses WHERE id = ?', { bizId }, function(result)
        if result and #result > 0 then
            cache[bizId] = result[1]
        else
            cache[bizId] = nil
        end
        cb(cache[bizId])
    end)
end

local function Save(biz)
    if not biz then return end
    cache[biz.id] = biz
    MySQL.update('UPDATE 196_businesses SET owner = ?, balance = ?, staff = ? WHERE id = ?', {
        biz.owner or '', biz.balance or 0, json.encode(biz.staff or {}), biz.id,
    })
end

-- ── Biznes məlumatı ──
RegisterNetEvent('196rp_business:server:getInfo', function(bizId)
    local src = source
    GetCached(bizId, function(biz)
        local cfg = GetBusiness(bizId)
        if not cfg then return end
        local isOwner = biz and biz.owner == QBCore.Functions.GetPlayer(src).PlayerData.citizenid
        local isStaff = false
        if biz and biz.staff then
            for _, cid in ipairs(biz.staff) do
                if cid == QBCore.Functions.GetPlayer(src).PlayerData.citizenid then isStaff = true end
            end
        end
        TriggerClientEvent('196rp_business:client:info', src, {
            bizId = bizId,
            exists = biz ~= nil, isOwner = isOwner, isStaff = isStaff,
            owner = biz and biz.owner or nil, balance = biz and biz.balance or 0,
            price = cfg.price, label = cfg.label,
        })
    end)
end)

-- ── Alış ──
RegisterNetEvent('196rp_business:server:buy', function(bizId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local cfg = GetBusiness(bizId)
    if not cfg then return end

    GetCached(bizId, function(biz)
        if biz and biz.owner and biz.owner ~= '' then
            Notify(src, 'Bu biznes artıq satılıb!', 'error')
            return
        end
        local cost = cfg.price
        local bank = Player.PlayerData.money.bank or 0
        if bank < cost then
            Notify(src, ('Kifayət qədər pul yoxdur — qiymət ₣%d'):format(cost), 'error')
            return
        end
        Player.Functions.RemoveMoney('bank', cost, 'biznes-alis')

        if biz then
            MySQL.update('UPDATE 196_businesses SET owner = ?, balance = 0, staff = ? WHERE id = ?', {
                Player.PlayerData.citizenid, json.encode({}), bizId,
            })
            cache[bizId].owner = Player.PlayerData.citizenid
            cache[bizId].balance = 0
            cache[bizId].staff = {}
        else
            MySQL.insert('INSERT INTO 196_businesses (id, type, label, owner, balance, staff, created_at) VALUES (?, ?, ?, ?, 0, ?, NOW())', {
                bizId, cfg.type, cfg.label, Player.PlayerData.citizenid, json.encode({}),
            })
            cache[bizId] = { id = bizId, owner = Player.PlayerData.citizenid, balance = 0, staff = {} }
        end
        Notify(src, ('🎉 %s biznesini aldınız (-₣%d)!'):format(cfg.label, cost), 'success')
    end)
end)

-- ── Kassa: yatır / çıxar ──
RegisterNetEvent('196rp_business:server:deposit', function(bizId, amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    amount = math.floor(tonumber(amount) or 0)
    if amount <= 0 or amount > 1000000 then
        Notify(src, 'Məbləğ 1 ₣ - 1 000 000 ₣ arası olmalıdır.', 'error')
        return
    end
    GetCached(bizId, function(biz)
        if not biz or biz.owner ~= Player.PlayerData.citizenid then return end
        if (Player.PlayerData.money.cash or 0) < amount then
            Notify(src, 'Cibinizdə kifayət qədər pul yoxdur.', 'error')
            return
        end
        Player.Functions.RemoveMoney('cash', amount, 'biznes-deposit')
        biz.balance = math.min((biz.balance or 0) + amount, Config.MaxBalance)
        Save(biz)
        Notify(src, ('✅ Kassaya yatırıldı: ₣%d'):format(amount), 'success')
    end)
end)

RegisterNetEvent('196rp_business:server:withdraw', function(bizId, amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    amount = math.floor(tonumber(amount) or 0)
    if amount <= 0 or amount > 1000000 then
        Notify(src, 'Məbləğ 1 ₣ - 1 000 000 ₣ arası olmalıdır.', 'error')
        return
    end
    GetCached(bizId, function(biz)
        if not biz or biz.owner ~= Player.PlayerData.citizenid then return end
        if (biz.balance or 0) < amount then
            Notify(src, 'Kassada kifayət qədər pul yoxdur.', 'error')
            return
        end
        biz.balance = (biz.balance or 0) - amount
        Save(biz)
        Player.Functions.AddMoney('cash', amount, 'biznes-withdraw')
        Notify(src, ('💵 Kassadan çıxarıldı: ₣%d'):format(amount), 'success')
    end)
end)

-- ── İşçilər ──
RegisterNetEvent('196rp_business:server:addStaff', function(bizId, targetSrc)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local Target = QBCore.Functions.GetPlayer(tonumber(targetSrc))
    if not Player or not Target then
        Notify(src, 'Hədəf tapılmadı!', 'error')
        return
    end
    local targetCid = Target.PlayerData.citizenid
    GetCached(bizId, function(biz)
        if not biz or biz.owner ~= Player.PlayerData.citizenid then return end
        biz.staff = biz.staff or {}
        for _, cid in ipairs(biz.staff) do
            if cid == targetCid then
                Notify(src, 'Bu şəxs artıq işçidir.', 'error')
                return
            end
        end
        biz.staff[#biz.staff + 1] = targetCid
        Save(biz)
        Notify(src, ('✅ İşçi əlavə olundu: %s'):format(Target.PlayerData.charinfo.firstname .. ' ' .. Target.PlayerData.charinfo.lastname), 'success')
        Notify(Target.PlayerData.source, ('Siz %s biznesində işçi təyin olundunuz!'):format(biz.id), 'success')
    end)
end)

RegisterNetEvent('196rp_business:server:removeStaff', function(bizId, cid)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    GetCached(bizId, function(biz)
        if not biz or biz.owner ~= Player.PlayerData.citizenid then return end
        biz.staff = biz.staff or {}
        local newStaff = {}
        for _, c in ipairs(biz.staff) do
            if c ~= cid then newStaff[#newStaff + 1] = c end
        end
        biz.staff = newStaff
        Save(biz)
        Notify(src, '🗑 İşçi silindi.', 'success')
    end)
end)

-- ── İşçi siyahısı ──
RegisterNetEvent('196rp_business:server:getStaff', function(bizId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    GetCached(bizId, function(biz)
        local list = {}
        if biz then
            for _, cid in ipairs(biz.staff or {}) do
                MySQL.query('SELECT citizenid, charinfo FROM players WHERE citizenid = ?', { cid }, function(r)
                    if r and #r > 0 then
                        local ok, info = pcall(json.decode, r[1].charinfo or '{}')
                        list[#list + 1] = {
                            cid = cid,
                            name = ok and (info.firstname .. ' ' .. info.lastname) or cid,
                        }
                    end
                end)
            end
        end
        -- gecikməli yığım — sadəcə bir az gözlə yığ
        SetTimeout(800, function()
            TriggerClientEvent('196rp_business:client:staff', src, list)
        end)
    end)
end)
