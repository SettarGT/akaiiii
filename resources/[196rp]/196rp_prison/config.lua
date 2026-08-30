Config = {}

-- Həbsxana iş zonaları (Bolingbroke həyəti ətrafı)
Config.WorkZones = {
    { id = 'kitchen', label = 'Mətbəx',       coords = vector3(1795.0, 2575.0, 44.85), icon = 'fas fa-utensils' },
    { id = 'clean',   label = 'Təmizlik',     coords = vector3(1730.0, 2596.0, 44.85), icon = 'fas fa-broom' },
    { id = 'gym',     label = 'İdman zalı',    coords = vector3(1765.67, 2565.91, 44.56), icon = 'fas fa-dumbbell' },
}

-- Hər işin effekti
Config.Effects = {
    kitchen = { seconds = 30, anim = 'amb@world_human_const_drill@male@drill@base', animName = 'base' },
    clean   = { seconds = 35, anim = 'amb@world_human_const_bush_trim@male@trim@base', animName = 'base' },
    gym     = { seconds = 30, anim = 'amb@world_human_pushups@male@base', animName = 'base' },
}

-- Müddət (saniyə) və cooldown
Config.WorkTime = 8
Config.Cooldown = 90
