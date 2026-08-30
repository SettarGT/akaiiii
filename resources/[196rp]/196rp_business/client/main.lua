local QBCore = exports['qb-core']:GetCoreObject()
local _lastBizId = nil

local function GetBusinessById(id)
    for _, b in ipairs(Config.Businesses) do
        if b.id == id then return b end
    end
end

-- ── İşçi idarəetməsi ──
local function OpenStaffMenu(bizId)
    local menu = {
        { header = '👥 İşçi idarəetməsi', isMenuHeader = true, icon = 'fas fa-users' },
        { header = '➕ İşçi əlavə et', txt = 'Yaxındakı oyunçunun ID-sini yaz', icon = 'fas fa-user-plus', params = { act = 'add' } },
        { header = '➖ İşçi sil', txt = 'İşçi siyahısından seç', icon = 'fas fa-user-minus', params = { act = 'list' } },
    }
    exports['qb-menu']:openMenu(menu, function(selected)
        if not selected or not selected.params then return end
        if selected.params.act == 'add' then
            local result = exports['qb-input']:ShowInput({
                header = 'İşçi əlavə et — oyunçu ID',
                submitText = 'Təsdiqlə',
                inputs = { { text = 'ID', name = 'target', type = 'number' } },
            })
            if result and result.target then
                TriggerServerEvent('196rp_business:server:addStaff', bizId, result.target)
            end
        elseif selected.params.act == 'list' then
            TriggerServerEvent('196rp_business:server:getStaff', bizId)
        end
    end)
end

-- ── Boss menyusu ──
local function OpenBossMenu(bizId)
    TriggerServerEvent('196rp_business:server:getInfo', bizId)
end

RegisterNetEvent('196rp_business:client:info', function(info)
    local cfg = GetBusinessById(info.bizId)
    if not cfg then return end
    local menu = {
        { header = '🏪 ' .. cfg.label, isMenuHeader = true, icon = 'fas fa-store' },
    }

    if not info.exists then
        menu[#menu + 1] = { header = '🛒 Biznesi al', txt = string.format('Qiymət: ₣%d (bankdan)', info.price), icon = 'fas fa-cart-plus', params = { act = 'buy' } }
    else
        menu[#menu + 1] = { header = '💼 Kassa balansı', txt = '₣' .. tostring(info.balance), icon = 'fas fa-vault', isDisabled = true }
        if info.isOwner or info.isStaff then
            menu[#menu + 1] = { header = '💵 Pul yatır', txt = 'Öz pulunu kassaya qoy', icon = 'fas fa-arrow-up', params = { act = 'deposit' } }
        end
        if info.isOwner then
            menu[#menu + 1] = { header = '💸 Pul çıxar', txt = 'Kassadan özünə götür', icon = 'fas fa-arrow-down', params = { act = 'withdraw' } }
            menu[#menu + 1] = { header = '👥 İşçilər', txt = 'İşçi əlavə et / sil', icon = 'fas fa-users', params = { act = 'staff' } }
        end
    end

    exports['qb-menu']:openMenu(menu, function(selected)
        if not selected or not selected.params then return end
        local act = selected.params.act
        if act == 'buy' then
            TriggerServerEvent('196rp_business:server:buy', cfg.id)
        elseif act == 'deposit' then
            local result = exports['qb-input']:ShowInput({
                header = 'Kassaya pul yatır (₣)',
                submitText = 'Təsdiqlə',
                inputs = { { text = 'Məbləğ', name = 'amount', type = 'number' } },
            })
            if result and result.amount then
                TriggerServerEvent('196rp_business:server:deposit', cfg.id, result.amount)
            end
        elseif act == 'withdraw' then
            local result = exports['qb-input']:ShowInput({
                header = 'Kassadan pul çıxar (₣)',
                submitText = 'Təsdiqlə',
                inputs = { { text = 'Məbləğ', name = 'amount', type = 'number' } },
            })
            if result and result.amount then
                TriggerServerEvent('196rp_business:server:withdraw', cfg.id, result.amount)
            end
        elseif act == 'staff' then
            OpenStaffMenu(cfg.id)
        end
    end)
end)

RegisterNetEvent('196rp_business:client:staff', function(staff)
    if not staff or #staff == 0 then
        QBCore.Functions.Notify('İşçi siyahısı boşdur.', 'primary')
        return
    end
    local menu = { { header = '👥 İşçilər', isMenuHeader = true, icon = 'fas fa-users' } }
    for _, s in ipairs(staff) do
        menu[#menu + 1] = {
            header = s.name,
            txt = 'Sil (FİN: ' .. s.cid .. ')',
            icon = 'fas fa-user-minus',
            params = { cid = s.cid },
        }
    end
    exports['qb-menu']:openMenu(menu, function(selected)
        if selected and selected.params and selected.params.cid and _lastBizId then
            TriggerServerEvent('196rp_business:server:removeStaff', _lastBizId, selected.params.cid)
        end
    end)
end)

CreateThread(function()
    for _, biz in ipairs(Config.Businesses) do
        local blip = AddBlipForCoord(biz.coords)
        SetBlipSprite(blip, 566)
        SetBlipColour(blip, 46)
        SetBlipScale(blip, 0.8)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName(biz.label)
        EndTextCommandSetBlipName(blip)

        exports['qb-target']:AddBoxZone('196biz_' .. biz.id, biz.coords, 3.0, 3.0, {
            name = '196biz_' .. biz.id, heading = biz.heading, debugPoly = false,
            minZ = biz.coords.z - 1, maxZ = biz.coords.z + 3,
        }, { options = { { label = '[E] ' .. biz.label .. ' — Biznes menyusu', icon = 'fas fa-store', action = function()
            _lastBizId = biz.id
            OpenBossMenu(biz.id)
        end } } })
    end
end)
