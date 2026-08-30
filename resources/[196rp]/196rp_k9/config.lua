Config = {}

-- İt modeli (German Shepherd — polis iti)
Config.DogModel = 'a_c_shepherd'

-- Axtarış parametrləri
Config.Search = {
    Radius = 15.0,      -- iyləmə radiusu (metr)
    Cooldown = 90,      -- axtarışlar arası (saniyə)
}

-- İylənəcək qadağan maddələr (silah + qaçaqmal — narkotik yoxdur!)
Config.IllegalItems = {
    'weapon_pistol', 'weapon_pistol_mk2', 'weapon_combatpistol', 'weapon_smg',
    'weapon_smg_mk2', 'weapon_rifle', 'weapon_carbinerifle', 'weapon_ak47',
    'weapon_assaultrifle', 'weapon_shotgun', 'weapon_sniper', 'weapon_bat',
    'weapon_knife', 'weapon_switchblade', 'weapon_battleaxe', 'weapon_hammer',
    'lockpick', 'advancedlockpick', 'screwdriverset',
    'drill', 'thermite', 'c4_bomb', 'black_money', 'diamond', 'goldbar',
    'weapon_gusenberg', 'weapon_heavysniper', 'weapon_microsmg',
    'armor', 'bag_duffel',
}
