Config = {}

Config.Key = 47 -- U düyməsi

Config.Animations = {
    { label = 'Otur', type = 'scenario', scenario = 'WORLD_HUMAN_SEAT_LEDGE' },
    { label = 'Otur (yerdə)', type = 'scenario', scenario = 'WORLD_HUMAN_PICNIC' },
    { label = 'Yerə uzan', type = 'scenario', scenario = 'WORLD_HUMAN_SUNBATHE' },
    { label = 'Siqaret çək', type = 'scenario', scenario = 'WORLD_HUMAN_SMOKING' },
    { label = 'Qəhvə iç', type = 'scenario', scenario = 'WORLD_HUMAN_DRINKING' },
    { label = 'Telefonda danış', type = 'scenario', scenario = 'WORLD_HUMAN_MOBILE_PHONE' },
    { label = 'Kompüterlə işlə', type = 'scenario', scenario = 'WORLD_HUMAN_STAND_MOBILE' },
    { label = 'Ayaq üstə gözlə', type = 'scenario', scenario = 'WORLD_HUMAN_AA_SMOKE' },
    { label = 'Yaz', type = 'scenario', scenario = 'WORLD_HUMAN_CLIPBOARD' },
    { label = 'Bax', type = 'scenario', scenario = 'WORLD_HUMAN_BINOCULARS' },
    { label = 'Salavat', type = 'scenario', scenario = 'WORLD_HUMAN_GUARD_STAND' },
    { label = 'Salam ver', dict = 'gestures@m@standing@casual', anim = 'gesture_hello' },
    { label = 'Əl yellə', dict = 'gestures@m@standing@casual', anim = 'gesture_wave' },
    { label = 'Ayağa qalx', dict = 'gestures@m@standing@casual', anim = 'gesture_cheer' },
    { label = 'Əlləri aç', dict = 'gestures@m@standing@casual', anim = 'gesture_howdy' },
    { label = 'Başını tərpət', dict = 'gestures@m@standing@casual', anim = 'gesture_nod_yes' },
    { label = 'Başını yoxla', dict = 'gestures@m@standing@casual', anim = 'gesture_nod_no' },
    { label = 'Rəqs et (klassik)', dict = 'anim@amb@nightclub@lazlow@hi_peds@', anim = 'low_center_dance_male_female' },
    { label = 'Rəqs et (klub)', dict = 'anim@amb@nightclub@lazlow@hi_peds@', anim = 'low_down_dance_male_female' },
    { label = 'Qazanc', dict = 'anim@amb@casino@valet@', anim = 'idle_a' },
    { label = 'İdman (təkan)', dict = 'amb@world_human_push_ups@male@base', anim = 'base' },
    { label = 'İdman (çömbəlmə)', dict = 'amb@world_human_squat@male@base', anim = 'base' },
    { label = 'Ağrı', dict = 'misscommon@respond', anim = 'pain_reaction' },
    { label = 'Sərxoş', dict = 'random@drunk_driving', anim = 'drunk_driver_lead_away_fail' },
}

Config.CancelAnims = {
    'WORLD_HUMAN_SEAT_LEDGE',
    'WORLD_HUMAN_PICNIC',
    'WORLD_HUMAN_SUNBATHE',
    'WORLD_HUMAN_SMOKING',
    'WORLD_HUMAN_DRINKING',
    'WORLD_HUMAN_MOBILE_PHONE',
    'WORLD_HUMAN_STAND_MOBILE',
    'WORLD_HUMAN_AA_SMOKE',
    'WORLD_HUMAN_CLIPBOARD',
    'WORLD_HUMAN_BINOCULARS',
    'WORLD_HUMAN_GUARD_STAND',
}
