-- 196 RP | Daşınmaz əmlak (evlər)

Config = {}

-- Bütün evlər üçün ortaq interyer (GTA V-də mövcud interyer)
Config.Interior = vector3(266.0, -1007.0, -38.0)

-- Əmlak agentliyi
Config.Agency = {
    name = 'Daşınmaz Əmlak Agentliyi',
    coords = vector3(-1350.0, -700.0, 25.0),
    blip = { sprite = 475, color = 3 }
}

-- Satışda olan evlər
Config.Houses = {
    { id = 'ev_1', name = 'Mənzil — Legion Meydanı', desc = 'Şəhərin mərkəzində rahat mənzil.', price = 150000, coords = vector3(230.0, -860.0, 30.5), heading = 160.0 },
    { id = 'ev_2', name = 'Mənzil — Vinewood', desc = 'Dəbdəbəli məhəllədə geniş mənzil.', price = 220000, coords = vector3(310.0, 190.0, 104.0), heading = 150.0 },
    { id = 'ev_3', name = 'Mənzil — Davis', desc = 'Sakit məhəllədə sərfəli mənzil.', price = 60000, coords = vector3(100.0, -1920.0, 21.0), heading = 330.0 },
    { id = 'ev_4', name = 'Sahil Evi — Del Perro', desc = 'Çimərliyə baxan gözəl sahil evi.', price = 350000, coords = vector3(-1450.0, -1000.0, 8.0), heading = 250.0 },
    { id = 'ev_5', name = 'Villa — Rockford Hills', desc = 'Şəhərin ən dəbdəbəli villası.', price = 1200000, coords = vector3(-740.0, 260.0, 99.0), heading = 20.0 },
    { id = 'ev_6', name = 'Kənd Evi — Grapeseed', desc = 'Təbiət qoynunda kənd evi.', price = 90000, coords = vector3(2450.0, 4960.0, 46.0), heading = 220.0 },
    { id = 'ev_7', name = 'Ev — Sandy Shores', desc = 'Səhrada rahat ailə evi.', price = 45000, coords = vector3(1600.0, 3700.0, 34.0), heading = 20.0 },
    { id = 'ev_8', name = 'Ev — Paleto Bay', desc = 'Sakit sahil şəhərində ev.', price = 80000, coords = vector3(-250.0, 6300.0, 32.0), heading = 320.0 },
    { id = 'ev_9', name = 'Ev — Harmony', desc = 'Yoldan kənarda sərfəli ev.', price = 55000, coords = vector3(400.0, 3590.0, 35.0), heading = 90.0 },
    { id = 'ev_10', name = 'Göl Evi — Alamo', desc = 'Gölə baxan mənzərəli ev.', price = 120000, coords = vector3(1320.0, 4250.0, 33.0), heading = 180.0 },
    { id = 'ev_11', name = 'Dağ Evi', desc = 'Təpədə, mənzərəli dağ evi.', price = 180000, coords = vector3(450.0, 5400.0, 150.0), heading = 270.0 },
    { id = 'ev_12', name = 'Mənzil — Strawberry', desc = 'Məhəllə həyatının ortasında mənzil.', price = 75000, coords = vector3(-1150.0, -900.0, 14.0), heading = 90.0 },
}

Config.GetHouse = function(id)
    for i = 1, #Config.Houses do
        if Config.Houses[i].id == id then
            return Config.Houses[i]
        end
    end
    return nil
end
