-- 196 RP | Mağazalar
-- Bütün məhsullar items cədvəlində qeyd olunub (bax: 196rp.sql)

Config = {}

Config.Shops = {
    {
        id = 'market_legion',
        name = '24/7 Market — Legion',
        coords = vector3(25.7, -1345.5, 29.5),
        blip = { sprite = 52, color = 3 },
        items = {
            { name = 'corek', label = 'Çörək', price = 5 },
            { name = 'su', label = 'Su', price = 3 },
            { name = 'kola', label = 'Kola', price = 4 },
            { name = 'qehve', label = 'Qəhvə', price = 6 },
            { name = 'sendvic', label = 'Sendviç', price = 7 },
            { name = 'burger', label = 'Burger', price = 8 },
            { name = 'hotdog', label = 'Hot-doq', price = 7 },
            { name = 'siqaret', label = 'Siqaret', price = 10 },
        }
    },
    {
        id = 'market_vinewood',
        name = '24/7 Market — Vinewood',
        coords = vector3(373.9, 325.8, 103.6),
        blip = { sprite = 52, color = 3 },
        items = {
            { name = 'corek', label = 'Çörək', price = 5 },
            { name = 'su', label = 'Su', price = 3 },
            { name = 'kola', label = 'Kola', price = 4 },
            { name = 'qehve', label = 'Qəhvə', price = 6 },
            { name = 'sendvic', label = 'Sendviç', price = 7 },
            { name = 'pizza', label = 'Pizza', price = 9 },
            { name = 'dondurma', label = 'Dondurma', price = 6 },
        }
    },
    {
        id = 'market_sandy',
        name = '24/7 Market — Sandy Shores',
        coords = vector3(549.2, 2669.2, 42.2),
        blip = { sprite = 52, color = 3 },
        items = {
            { name = 'corek', label = 'Çörək', price = 5 },
            { name = 'su', label = 'Su', price = 3 },
            { name = 'kola', label = 'Kola', price = 4 },
            { name = 'sendvic', label = 'Sendviç', price = 7 },
            { name = 'siqaret', label = 'Siqaret', price = 10 },
        }
    },
    {
        id = 'market_paleto',
        name = '24/7 Market — Paleto Bay',
        coords = vector3(-3038.9, 585.9, 7.9),
        blip = { sprite = 52, color = 3 },
        items = {
            { name = 'corek', label = 'Çörək', price = 5 },
            { name = 'su', label = 'Su', price = 3 },
            { name = 'kola', label = 'Kola', price = 4 },
            { name = 'sendvic', label = 'Sendviç', price = 7 },
        }
    },
    {
        id = 'market_ocean',
        name = '24/7 Market — Great Ocean',
        coords = vector3(-3241.9, 1001.2, 12.8),
        blip = { sprite = 52, color = 3 },
        items = {
            { name = 'corek', label = 'Çörək', price = 5 },
            { name = 'su', label = 'Su', price = 3 },
            { name = 'kola', label = 'Kola', price = 4 },
            { name = 'siqaret', label = 'Siqaret', price = 10 },
        }
    },
    {
        id = 'supermarket',
        name = 'Rob\'s Supermarket',
        coords = vector3(-706.0, -905.0, 19.2),
        blip = { sprite = 52, color = 3 },
        items = {
            { name = 'corek', label = 'Çörək', price = 5 },
            { name = 'su', label = 'Su', price = 3 },
            { name = 'kola', label = 'Kola', price = 4 },
            { name = 'qehve', label = 'Qəhvə', price = 6 },
            { name = 'sendvic', label = 'Sendviç', price = 7 },
            { name = 'burger', label = 'Burger', price = 8 },
            { name = 'hotdog', label = 'Hot-doq', price = 7 },
            { name = 'pizza', label = 'Pizza', price = 9 },
            { name = 'dondurma', label = 'Dondurma', price = 6 },
            { name = 'pive', label = 'Pivə', price = 12 },
            { name = 'serab', label = 'Şərab', price = 25 },
            { name = 'siqaret', label = 'Siqaret', price = 10 },
        }
    },
    {
        id = 'aptek',
        name = 'Mərkəzi Aptek',
        coords = vector3(176.0, -1300.0, 29.4),
        blip = { sprite = 403, color = 3 },
        items = {
            { name = 'bandaj', label = 'Bandaj', price = 15 },
            { name = 'tibbi_dest', label = 'Tibbi dəst', price = 60 },
        }
    },
    {
        id = 'bar_vanilla',
        name = 'Vanilla Unicorn — Bar',
        coords = vector3(127.4, -1304.0, 29.3),
        blip = { sprite = 93, color = 2 },
        items = {
            { name = 'pive', label = 'Pivə', price = 12 },
            { name = 'serab', label = 'Şərab', price = 25 },
            { name = 'araq', label = 'Araq', price = 30 },
        }
    },
    {
        id = 'baliq_dukani',
        name = 'Balıqçılıq Alətləri Mağazası',
        coords = vector3(48.0, -1100.0, 29.5),
        blip = { sprite = 68, color = 38 },
        items = {
            { name = 'baliqci_desti', label = 'Balıqçılıq dəsti', price = 50 },
            { name = 'yem', label = 'Balıq yemi', price = 5 },
        }
    },
    {
        id = 'mexanik_dukani',
        name = 'Mexanik Avadanlıq Mağazası',
        coords = vector3(488.4, -1318.7, 29.2),
        blip = { sprite = 72, color = 66 },
        items = {
            { name = 'temir_desti', label = 'Təmir dəsti', price = 100 },
            { name = 'shom', label = 'Şom (qıfıl açma)', price = 350 },
        }
    }
}

Config.GetShop = function(id)
    for i = 1, #Config.Shops do
        if Config.Shops[i].id == id then
            return Config.Shops[i]
        end
    end
    return nil
end
