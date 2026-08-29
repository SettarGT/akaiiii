-- 196 RP | Ev daxili imkanlar — müştəri tərəfi
-- Açarlar, seyf, divar rəngi, icarə, ev telefonu, balkon, qonaqlar, yataq

local currentHouse = nil       -- { house_id, name }
local wallColor = nil          -- { r, g, b }

-- ==================== KÖMƏKÇİLƏR ====================

local function Notify(msg, typ, len)
    ESX.ShowNotification(msg, typ or 'info', len or 6000)
end

local function IsInside()
    return #(GetEntityCoords(PlayerPedId()) - Config.Interior) < Config.InteriorDist
end

local function RefreshHouse()
    ESX.TriggerServerCallback('196rp_home:getAccessHouse', function(house, colorIndex)
        currentHouse = house

        if colorIndex and Config.WallColors[colorIndex] then
            local c = Config.WallColors[colorIndex].rgb
            wallColor = { c[1] / 255, c[2] / 255, c[3] / 255 }
        else
            wallColor = nil
        end
    end)
end

-- ==================== 74. DİVAR RƏNGİ (işıq effekti) ====================

CreateThread(function()
    while true do
        Wait(0)

        if wallColor and IsInside() then
            DrawLightWithRange(
                Config.Points.wall.x, Config.Points.wall.y, Config.Points.wall.z + 1.5,
                wallColor[1], wallColor[2], wallColor[3],
                Config.WallLight.range, Config.WallLight.intensity)
        end
    end
end)

-- ==================== 80. YATAQ ====================

local function Sleep()
    ESX.Progressbar('Yatırsınız...', Config.Bed.sleepTime, {
        FreezePlayer = true,
        animation = { type = 'Scenario', Scenario = 'WORLD_HUMAN_PICNIC' },
        onFinish = function()
            ESX.TriggerServerCallback('196rp_home:sleep', function(ok, msg)
                Notify(msg, ok and 'success' or 'error')

                if ok then
                    local ped = PlayerPedId()
                    SetEntityHealth(ped, math.min(GetEntityMaxHealth(ped), GetEntityHealth(ped) + Config.Bed.healAmount))
                    DoScreenFadeOut(800)
                    Wait(2500)
                    DoScreenFadeIn(800)
                    Notify('~g~Yaxşı yatdınız!~s~ Doğulma nöqtəsi evinizdə saxlanıldı.', 'success')
                end
            end, currentHouse and currentHouse.house_id)
        end,
    })
end

local function RelaxOnBalcony()
    ESX.Progressbar('Balkonda dincəlirsiniz...', Config.Balcony.restTime, {
        FreezePlayer = true,
        animation = { type = 'Scenario', Scenario = 'WORLD_HUMAN_LEANING' },
        onFinish = function()
            ESX.TriggerServerCallback('196rp_home:relax', function(ok, msg)
                Notify(msg, ok and 'success' or 'error')
            end)
        end,
    })
end

-- ==================== 73. SEYF ====================

local function OpenSafe()
    local houseId = currentHouse and currentHouse.house_id
    if not houseId then
        return Notify('Sizin eviniz yoxdur!', 'error')
    end

    ESX.TriggerServerCallback('196rp_home:getSafe', function(ok, money, items)
        if not ok then
            ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'safe_buy', {
                title = 'Seyf',
                align = 'top-left',
                elements = {
                    { label = ('Seyf al — ~g~%s$~s~'):format(Config.Safe.price), value = 'buy' },
                }
            }, function(data, menu)
                menu.close()
                ESX.TriggerServerCallback('196rp_home:buySafe', function(bought, msg)
                    Notify(msg, bought and 'success' or 'error')
                end, houseId)
            end, function(data, menu)
                menu.close()
            end)
            return
        end

        local elements = {
            { label = ('💰 Nağd pul: ~g~%s$~s~'):format(money), value = 'none' },
            { label = 'Pul qoy', value = 'deposit_money' },
            { label = 'Pul götür', value = 'withdraw_money' },
            { label = 'Əşya qoy', value = 'deposit_item' },
            { label = ('Əşyalar (%s növ)'):format(#items), value = 'items' },
        }

        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'safe_menu', {
            title = ('🔐 %s — Seyf'):format(currentHouse.name),
            align = 'top-left',
            elements = elements,
        }, function(data, menu)
            local action = data.current.value

            if action == 'deposit_money' or action == 'withdraw_money' then
                ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'safe_amount', {
                    title = 'Məbləğ ($)'
                }, function(data2, menu2)
                    menu2.close()
                    local amount = math.floor(tonumber(data2.value) or 0)

                    ESX.TriggerServerCallback(action == 'deposit_money'
                            and '196rp_home:depositMoney' or '196rp_home:withdrawMoney',
                        function(done, msg)
                            Notify(msg, done and 'success' or 'error')
                            if done then
                                menu.close()
                                RefreshHouse()
                            end
                        end, houseId, amount)
                end)
            elseif action == 'deposit_item' then
                ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'safe_item', {
                    title = 'Əşyanın adı'
                }, function(data2, menu2)
                    menu2.close()
                    local item = tostring(data2.value or ''):lower():gsub('%s+', '')
                    if item == '' then
                        return
                    end

                    ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'safe_item_count', {
                        title = 'Neçə ədəd?'
                    }, function(data3, menu3)
                        menu3.close()
                        local count = math.floor(tonumber(data3.value) or 0)

                        ESX.TriggerServerCallback('196rp_home:depositItem', function(done, msg)
                            Notify(msg, done and 'success' or 'error')
                        end, houseId, item, count)
                    end)
                end)
            elseif action == 'items' then
                local sub = {}
                if #items == 0 then
                    sub[#sub + 1] = { label = 'Seyfdə əşya yoxdur', value = 'none' }
                end
                for i = 1, #items do
                    sub[#sub + 1] = {
                        label = ('%s — %s ədəd'):format(items[i].label or items[i].item, items[i].count),
                        value = items[i].item,
                    }
                end

                ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'safe_items', {
                    title = 'Seyfdəki əşyalar',
                    align = 'top-left',
                    elements = sub,
                }, function(data3, menu3)
                    local item = data3.current.value
                    if item == 'none' then
                        menu3.close()
                        return
                    end

                    ESX.TriggerServerCallback('196rp_home:withdrawItem', function(done, msg)
                        Notify(msg, done and 'success' or 'error')
                        if done then
                            menu3.close()
                        end
                    end, houseId, item)
                end, function(data3, menu3)
                    menu3.close()
                end)
            end
        end, function(data, menu)
            menu.close()
        end)
    end, houseId)
end

-- ==================== 74. DİVAR RƏNGİ ====================

local function ChangeWall()
    local houseId = currentHouse and currentHouse.house_id
    if not houseId then
        return Notify('Sizin eviniz yoxdur!', 'error')
    end

    local elements = {}
    for i = 1, #Config.WallColors do
        elements[#elements + 1] = { label = ('🎨 %s'):format(Config.WallColors[i].label), value = i }
    end

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'wall_menu', {
        title = 'Divar rəngi',
        align = 'top-left',
        elements = elements,
    }, function(data, menu)
        menu.close()

        ESX.TriggerServerCallback('196rp_home:setWallColor', function(ok, msg)
            Notify(msg, ok and 'success' or 'error')
            if ok then
                RefreshHouse()
            end
        end, houseId, data.current.value)
    end, function(data, menu)
        menu.close()
    end)
end

-- ==================== 71. AÇARLAR / 79. QONAQLAR ====================

local function ManagePeople(kind)
    local houseId = currentHouse and currentHouse.house_id
    if not houseId then
        return Notify('Sizin eviniz yoxdur!', 'error')
    end

    local cbName = kind == 'key' and '196rp_home:getKeys' or '196rp_home:getGuests'

    ESX.TriggerServerCallback(cbName, function(list)
        local elements = {}

        if kind == 'key' then
            elements[#elements + 1] = { label = '🔑 Açar ver (server ID ilə)', value = 'add' }
        else
            elements[#elements + 1] = { label = '👥 Qonaq dəvət et (server ID ilə)', value = 'add' }
        end

        if #list == 0 then
            elements[#elements + 1] = { label = 'Siyahı boşdur', value = 'none' }
        end

        for i = 1, #list do
            elements[#elements + 1] = {
                label = ('❌ %s (server ID %s)'):format(list[i].name, list[i].source or '—'),
                value = list[i].identifier,
            }
        end

        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'people_menu', {
            title = kind == 'key' and 'Ev açarları' or 'Ev qonaqları',
            align = 'top-left',
            elements = elements,
        }, function(data, menu)
            local val = data.current.value

            if val == 'none' then
                return
            end

            if val == 'add' then
                ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'people_add', {
                    title = 'Oyunçunun server ID-si'
                }, function(data2, menu2)
                    menu2.close()
                    local target = math.floor(tonumber(data2.value) or 0)

                    ESX.TriggerServerCallback(kind == 'key' and '196rp_home:giveKey' or '196rp_home:addGuest',
                        function(ok, msg)
                            Notify(msg, ok and 'success' or 'error')
                            if ok then
                                menu.close()
                            end
                        end, houseId, target)
                end)
            else
                ESX.TriggerServerCallback(kind == 'key' and '196rp_home:revokeKey' or '196rp_home:removeGuest',
                    function(ok, msg)
                        Notify(msg, ok and 'success' or 'error')
                        if ok then
                            menu.close()
                        end
                    end, houseId, val)
            end
        end, function(data, menu)
            menu.close()
        end)
    end, houseId)
end

-- ==================== 75. İCARƏ ====================

local function ManageRent()
    local houseId = currentHouse and currentHouse.house_id

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'rent_menu', {
        title = '🏠 Ev icarəsi',
        align = 'top-left',
        elements = {
            { label = 'Kirayə evlərə bax', value = 'list' },
            { label = 'Evimi icarəyə ver (sahib üçün)', value = 'set' },
            { label = 'İcarəni dayandır (sahib üçün)', value = 'stop' },
        },
    }, function(data, menu)
        local action = data.current.value

        if action == 'list' then
            ESX.TriggerServerCallback('196rp_home:getRentals', function(rentals)
                local sub = {}

                if #rentals == 0 then
                    sub[#sub + 1] = { label = 'Hal-hazırda kirayə ev yoxdur', value = 'none' }
                end

                for i = 1, #rentals do
                    sub[#sub + 1] = {
                        label = ('%s — ~g~%s$~s~ / %s saat'):format(
                            rentals[i].name, rentals[i].price, Config.Rent.periodHours),
                        value = rentals[i].house_id,
                    }
                end

                ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'rent_list', {
                    title = 'Kirayə evlər',
                    align = 'top-left',
                    elements = sub,
                }, function(data2, menu2)
                    local id = data2.current.value
                    if id == 'none' then
                        menu2.close()
                        return
                    end

                    ESX.TriggerServerCallback('196rp_home:rentHouse', function(ok, msg)
                        Notify(msg, ok and 'success' or 'error', 8000)
                        if ok then
                            menu2.close()
                            menu.close()
                            RefreshHouse()
                        end
                    end, id)
                end, function(data2, menu2)
                    menu2.close()
                end)
            end)
        elseif action == 'set' then
            if not houseId then
                return Notify('Sizin eviniz yoxdur!', 'error')
            end

            ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'rent_price', {
                title = ('İcarə qiyməti (%s - %s)'):format(Config.Rent.minPrice, Config.Rent.maxPrice)
            }, function(data2, menu2)
                menu2.close()
                local price = math.floor(tonumber(data2.value) or 0)

                ESX.TriggerServerCallback('196rp_home:listRent', function(ok, msg)
                    Notify(msg, ok and 'success' or 'error')
                end, houseId, price)
            end)
        elseif action == 'stop' then
            if not houseId then
                return Notify('Sizin eviniz yoxdur!', 'error')
            end

            ESX.TriggerServerCallback('196rp_home:stopRent', function(ok, msg)
                Notify(msg, ok and 'success' or 'error')
            end, houseId)
        end
    end, function(data, menu)
        menu.close()
    end)
end

-- ==================== 76. EV TELEFONU ====================

local function UsePhone()
    ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'house_phone', {
        title = '☎️ Ev telefonu — nömrəni yığın'
    }, function(data, menu)
        menu.close()
        local number = tostring(data.value or ''):gsub('%s', '')

        if number == '' then
            return Notify('Nömrə yazın!', 'error')
        end

        Notify(('~g~%s~s~ nömrəsinə zəng edilir...'):format(number), 'info', 5000)
        TriggerServerEvent('196rp_phone:call', number)
    end)
end

-- ==================== ƏSAS MENYU (/ev) ====================

RegisterCommand('ev', function()
    RefreshHouse()

    local elements = {
        { label = '🛏️ Yataq (spawn nöqtəsi)', value = 'bed' },
        { label = '🔐 Seyf', value = 'safe' },
        { label = '🎨 Divar rəngi', value = 'wall' },
        { label = '🏠 Ev icarəsi', value = 'rent' },
        { label = '🔑 Ev açarları', value = 'keys' },
        { label = '👥 Qonaqlar', value = 'guests' },
        { label = '🌿 Balkon / bağça', value = 'balcony' },
        { label = '☎️ Ev telefonu', value = 'phone' },
    }

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'home_menu', {
        title = currentHouse and ('🏠 %s'):format(currentHouse.name) or '🏠 Ev menyusu',
        align = 'top-left',
        elements = elements,
    }, function(data, menu)
        menu.close()
        local action = data.current.value

        if action == 'bed' then
            Sleep()
        elseif action == 'safe' then
            OpenSafe()
        elseif action == 'wall' then
            ChangeWall()
        elseif action == 'rent' then
            ManageRent()
        elseif action == 'keys' then
            ManagePeople('key')
        elseif action == 'guests' then
            ManagePeople('guest')
        elseif action == 'phone' then
            UsePhone()
        elseif action == 'balcony' then
            RelaxOnBalcony()
        end
    end, function(data, menu)
        menu.close()
    end)
end, false)

-- ==================== MARKERLƏR ====================

local InteriorPoints = {
    { p = Config.Points.bed,     label = '[E] — Yataq (spawn nöqtəsi)', action = Sleep },
    { p = Config.Points.safe,    label = '[E] — Seyf',                   action = OpenSafe },
    { p = Config.Points.wall,    label = '[E] — Divar rəngi',            action = ChangeWall },
    { p = Config.Points.phone,   label = '[E] — Ev telefonu',            action = UsePhone },
    { p = Config.Points.balcony, label = '[E] — Balkonda dincəl',        action = RelaxOnBalcony },
}


CreateThread(function()
    while true do
        local wait = 750

        if IsInside() then
            wait = 0
            local coords = GetEntityCoords(PlayerPedId())
            local shown = false

            for i = 1, #InteriorPoints do
                local pt = InteriorPoints[i]

                DrawMarker(1, pt.p.x, pt.p.y, pt.p.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                    0.8, 0.8, 0.4, 240, 200, 90, 110, false, true, 2, nil, nil, false)

                if #(coords - pt.p) < Config.MarkerDist then
                    shown = true
                    ESX.TextUI(pt.label, 'info')

                    if IsControlJustPressed(0, 38) then
                        ESX.HideUI()

                        if pt.action then
                            pt.action()
                        end
                    end
                end
            end

            if not shown then
                ESX.HideUI()
            end
        else
            ESX.HideUI()
        end

        Wait(wait)
    end
end)

-- ==================== GİRİŞ / SPAWN ====================

RegisterNetEvent('196rp_home:refresh', function()
    RefreshHouse()
end)

RegisterNetEvent('196rp_home:goSpawn', function(coords, heading)
    local ped = PlayerPedId()
    DoScreenFadeOut(600)
    Wait(700)
    SetEntityCoords(ped, coords.x, coords.y, coords.z, false, false, false, true)
    SetEntityHeading(ped, heading or 0.0)
    DoScreenFadeIn(600)
    Notify('~g~Evdə oyandınız.~s~', 'success', 5000)
end)

CreateThread(function()
    Wait(3000)
    RefreshHouse()
end)

exports('GetCurrentHouse', function()
    return currentHouse
end)
