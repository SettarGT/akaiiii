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
    { name = 'pizzaboy',   label = 'Pizza çatdırma', icon = '🍕', desc = 'Pizzaları ünvana çatdırın.', salary = 60 },
    { name = 'courier',    label = 'Kuryer',    icon = '📦', desc = 'Bağlamaları şəhər boyu çatdırın.', salary = 70 },
    { name = 'trucker',    label = 'Yük daşıma', icon = '🚚', desc = 'Şəhərlərarası yük daşıyın.', salary = 120 },
    { name = 'electrician',label = 'Elektrikçi',icon = '🔌', desc = 'Elektrik xətlərini təmir edin.', salary = 110 },
    { name = 'plumber',    label = 'Santexnik', icon = '🔧', desc = 'Su borularını təmir edin.', salary = 100 },
    { name = 'gardener',   label = 'Bağban',    icon = '🌱', desc = 'Parklarda bitki əkin və suvarın.', salary = 80 },
    { name = 'dancer',     label = 'Rəqqasə / Rəqqas', icon = '💃', desc = 'Gecə klubunda səhnəyə çıxın.', salary = 90 },
    { name = 'beekeeper',  label = 'Arıçı',     icon = '🐝', desc = 'Pətək qurun və bal toplayın.', salary = 80 },
    { name = 'farmer',     label = 'Heyvandar', icon = '🐄', desc = 'Fermada heyvanlara qulluq edin.', salary = 85 },
    { name = 'pharmacist', label = 'Əczaçı',    icon = '💊', desc = 'Aptekdə dərman hazırlayın və satın.', salary = 110 },
    { name = 'doctor',     label = 'Həkim',     icon = '🩺', desc = 'Xəstəxanada növbətçi həkim olun.', salary = 140 },
    { name = 'dentist',    label = 'Stomatoloq',icon = '🦷', desc = 'Diş klinikasında xəstə qəbul edin.', salary = 180 },
    { name = 'vet',        label = 'Veterinar', icon = '🐾', desc = 'Heyvanları müayinə və müalicə edin.', salary = 150 },
    { name = 'beautician', label = 'Gözəllik salonu', icon = '💅', desc = 'Manikür və makiyaj xidməti göstərin.', salary = 95 },
    { name = 'masseur',    label = 'Masaj ustası', icon = '💆', desc = 'Masaj xidməti ilə pul qazanın.', salary = 100 },
    { name = 'detailer',   label = 'Detallinq', icon = '✨', desc = 'Maşınları cilalayıb parladın.', salary = 100 },
    { name = 'realestate', label = 'Əmlak agenti', icon = '🏠', desc = 'Ev satışında nümayiş keçirin, komissiya alın.', salary = 130 },
    { name = 'ticketeer',  label = 'Bilet satıcısı', icon = '🎟️', desc = 'Tədbirlərə bilet satın.', salary = 70 },
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
    ['pizzaboy'] = 'Pizza çatdırma',
    ['courier'] = 'Kuryer',
    ['trucker'] = 'Yük daşıma',
    ['electrician'] = 'Elektrikçi',
    ['plumber'] = 'Santexnik',
    ['gardener'] = 'Bağban',
    ['dancer'] = 'Rəqqasə / Rəqqas',
    ['beekeeper'] = 'Arıçı',
    ['farmer'] = 'Heyvandar',
    ['pharmacist'] = 'Əczaçı',
    ['doctor'] = 'Həkim',
    ['dentist'] = 'Stomatoloq',
    ['vet'] = 'Veterinar',
    ['beautician'] = 'Gözəllik salonu',
    ['masseur'] = 'Masaj ustası',
    ['detailer'] = 'Detallinq',
    ['realestate'] = 'Əmlak agenti',
    ['ticketeer'] = 'Bilet satıcısı',
    ['motodeliver'] = 'Motodeliver',
    ['firefighter'] = 'Yanğınsöndürən',
}
