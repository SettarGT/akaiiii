Config = {}

-- Növbət panelləri (kiosk yerləri)
Config.Panels = {
    { label = 'PD Növbət Paneli', coords = vector3(441.44, -981.31, 30.7), heading = 0.0 },
    { label = 'Xəstəxana Növbət Paneli', coords = vector3(307.69, -594.16, 43.18), heading = 0.0 },
    { label = 'İş Mərkəzi Növbət Paneli', coords = vector3(-266.63, -965.76, 31.22), heading = 0.0 },
}

-- Paneldə göstərilən işlər
Config.Jobs = {
    { name = 'police',    label = 'Polis',         icon = '🛡️', color = '#7dd3fc' },
    { name = 'ambulance', label = 'Təcili yardım',  icon = '🚑', color = '#ff6b6b' },
    { name = 'mechanic',  label = 'Mexanik',        icon = '🔧', color = '#ffd97a' },
    { name = 'tow',       label = 'Yedək xidməti',  icon = '🚛', color = '#f0a35e' },
    { name = 'judge',     label = 'Məhkəmə',        icon = '⚖️', color = '#c5a3ff' },
    { name = 'reporter',  label = 'Reporter',       icon = '📷', color = '#8fe3c2' },
}
