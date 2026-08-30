Config = {}

-- MDT-yə kim giriş edə bilər
Config.AccessJobs = { police = true, judge = true, sheriff = true }

-- Ən çox istifadə olunan cərimələr (MDT içindən seçilir)
Config.Fines = {
    { label = 'Sürət həddi',          amount = 500 },
    { label = 'Qırmızı işıq',         amount = 750 },
    { label = 'Yanlış park',          amount = 400 },
    { label = 'Təhlükəsizlik kəməri', amount = 350 },
    { label = 'Alkoqol vəziyyəti',    amount = 1500 },
    { label = 'Qanunsuz silah',       amount = 3000 },
    { label = 'Narkotik',             amount = 5000 },
    { label = 'Polisə müqavimət',     amount = 2500 },
    { label = 'Maşın oğurluğu',       amount = 4000 },
    { label = 'Xuliqanlıq',           amount = 2000 },
}

-- F6 düyməsi ilə MDT açmaq
Config.Keybind = 113 -- F6
