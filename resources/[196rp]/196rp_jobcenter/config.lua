Config = {}

-- İş lövhələrinin yerləşdiyi yerlər (Bələdiyyə binası + İş Mərkəzi)
Config.Boards = {
    { coords = vector3(246.0, -687.0, 30.5), label = 'Bələdiyyə — İş Elanları Lövhəsi' },
    { coords = vector3(-268.0, -957.0, 31.2), label = 'İş Mərkəzi — Elanlar Lövhəsi' },
}

-- Xidmət işləri (oyunçu buradan işə götürülür)
Config.PublicJobs = {
    { name = 'police',    label = 'Polis',      icon = '🚓', desc = 'Şəhər qaydasını qoruyun. Rütbə ilə maaş artır.', minGrade = 0 },
    { name = 'ambulance', label = 'Təcili Yardım', icon = '🚑', desc = 'Yaralılara kömək edin, həyat qurtarın.', minGrade = 0 },
    { name = 'taxi',      label = 'Taksi',       icon = '🚕', desc = 'Sərnişin daşıyın, pul qazanın.', minGrade = 0 },
    { name = 'mechanic',  label = 'Mexanik',     icon = '🔧', desc = 'Avtomobilləri təmir edin və tənzimləyin.', minGrade = 0 },
}

-- Bələdiyyə işləri (yeni işçilər üçün — aşağı rütbədən başlayır)
Config.MunicipalJobs = {
    { name = 'lumberjack', label = 'Meşəçi',   icon = '🪓', desc = 'Meşədə ağac kəsin və satın.', salary = 80 },
    { name = 'miner',      label = 'Mədənçi',  icon = '⛏️', desc = 'Dağda filiz çıxarın.', salary = 90 },
    { name = 'fisherman',  label = 'Balıqçı',  icon = '🎣', desc = 'Dənizdə balıq tutun.', salary = 70 },
    { name = 'slaughterer',label = 'Qəssab',   icon = '🥩', desc = 'Ət hazırlayın və satın.', salary = 85 },
    { name = 'tailor',     label = 'Dərzi',    icon = '🧵', desc = 'Parçadan geyimlər hazırlayın.', salary = 75 },
    { name = 'fueler',     label = 'Yanacaqçı',icon = '⛽', desc = 'Yanacaq anbarında işləyin.', salary = 70 },
    { name = 'cardealer',  label = 'Avtosalonçu', icon = '🚗', desc = 'Avtomobil satın.', salary = 110 },
    { name = 'reporter',   label = 'Jurnalist', icon = '📰', desc = 'Şəhər xəbərlərini toplayın.', salary = 65 },
}

-- Azərbaycan dilində iş adları (xidmət işləri üçün)
Config.JobNameMap = {
    ['police'] = 'Polis',
    ['ambulance'] = 'Təcili Yardım',
    ['taxi'] = 'Taksi',
    ['mechanic'] = 'Mexanik',
    ['lumberjack'] = 'Meşəçi',
    ['miner'] = 'Mədənçi',
    ['fisherman'] = 'Balıqçı',
    ['slaughterer'] = 'Qəssab',
    ['tailor'] = 'Dərzi',
    ['fueler'] = 'Yanacaqçı',
    ['cardealer'] = 'Avtosalonçu',
    ['reporter'] = 'Jurnalist',
}
