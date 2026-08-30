Config = {}

-- Həbsxana iş zonaları (Bolingbroke həyəti)
Config.WorkZones = {
    { id = 'kitchen', label = 'Mətbəx',    coords = vector3(1770.0, 2590.0, 44.9),  icon = 'fas fa-utensils' },
    { id = 'clean',   label = 'Təmizlik',  coords = vector3(1740.0, 2600.0, 44.9),  icon = 'fas fa-broom' },
    { id = 'gym',     label = 'İdman zalı', coords = vector3(1765.67, 2565.91, 44.56), icon = 'fas fa-dumbbell' },
}

-- İş vaxtı (saniyə) və azaltma (həbs saniyəsi)
Config.WorkTime = { kitchen = 8, clean = 10, gym = 8 }
Config.Reduce = { kitchen = 30, clean = 40, gym = 30 }

-- Cooldown (saniyə)
Config.Cooldown = 90
