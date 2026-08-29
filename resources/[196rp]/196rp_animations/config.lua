Config = {}

-- Animasiya kateqoriyaları
-- növ: 'scenario' (TaskStartScenarioInPlace) və ya 'anim' (TaskPlayAnim)
Config.Categories = {
    {
        name = 'oturmaq',
        label = '🪑 Oturmaq',
        items = {
            { label = 'Skamyada otur', scenario = 'PROP_HUMAN_SEAT_BENCH' },
            { label = 'Yerdə otur', scenario = 'WORLD_HUMAN_PICNIC' },
            { label = 'Divanda otur', scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER' },
            { label = 'Dəzgahda otur (iş)', scenario = 'PROP_HUMAN_SEAT_SEWING' },
            { label = 'Kresloda otur', scenario = 'PROP_HUMAN_SEAT_MUSCLE_BENCH_PRESS' },
            { label = 'Stulda otur', scenario = 'PROP_HUMAN_SEAT_CHAIR' },
        }
    },
    {
        name = 'salam',
        label = '👋 Salam və jestlər',
        items = {
            { label = 'Əl yellə', dict = 'mp_facial', lib = 'shrug_0' },
            { label = 'Salam ver', dict = 'gestures@m@standing@casual', lib = 'gesture_hello' },
            { label = 'Baş əy', dict = 'gestures@m@standing@casual', lib = 'gesture_bow' },
            { label = 'Baş yellə (hə)', dict = 'gestures@m@standing@casual', lib = 'gesture_nod_yes_hard' },
            { label = 'Baş yellə (yox)', dict = 'gestures@m@standing@casual', lib = 'gesture_no_soft' },
            { label = 'Çiyin çək', dict = 'gestures@m@standing@casual', lib = 'gesture_shrug_hard' },
            { label = 'Hərbi salam', dict = 'mp_player_int_upperarse_pick', lib = 'mp_player_int_arse_pick' },
            { label = 'Yumruq vur (salamlaşma)', dict = 'gestures@m@standing@casual', lib = 'gesture_hand_forward' },
        }
    },
    {
        name = 'faaliyyet',
        label = '💼 Fəaliyyətlər',
        items = {
            { label = 'Telefonla danış', dict = 'cellphone@', lib = 'cellphone_call_listen_base' },
            { label = 'Telefona bax', dict = 'cellphone@', lib = 'cellphone_text_read_base' },
            { label = 'Siqaret çək', dict = 'amb@world_human_smoking@male@male_a@base', lib = 'base' },
            { label = 'Qəzet oxu', dict = 'amb@world_human_seat_wall_table@male@male_a@base', lib = 'base' },
            { label = 'Qol çarpazla', dict = 'amb@world_human_cross_road@male@base', lib = 'base' },
            { label = 'Ayaq üstə dayan', dict = 'amb@world_human_stand_guard@base', lib = 'base' },
            { label = 'Gözlə (küçədə)', dict = 'amb@world_human_stand_impatient@male@base', lib = 'base' },
            { label = 'Alqışla', dict = 'amb@world_human_cheering@male_a@base', lib = 'base' },
        }
    },
    {
        name = 'isek',
        label = '🥤 İçki / yemək',
        items = {
            { label = 'Stəkandan iç', dict = 'mp_player_intdrink', lib = 'intro_bottle' },
            { label = 'Şüşədən iç', dict = 'amb@world_human_drinking@beer@male@base', lib = 'base' },
            { label = 'Kofe iç', dict = 'amb@world_human_drinking@coffee@male@base', lib = 'base' },
            { label = 'Yemək ye', dict = 'amb@code_human_in_car_mp_actions@eat@b_base@base', lib = 'base' },
            { label = 'Burger ye', dict = 'amb@code_human_in_car_mp_actions@eat@burrito@base', lib = 'base' },
        }
    },
    {
        name = 'idman',
        label = '🏋️ İdman',
        items = {
            { label = 'Ştanq qaldır', dict = 'amb@world_human_muscle_flex@base', lib = 'base' },
            { label = 'Təkan qaldır', dict = 'amb@world_human_push_ups@base', lib = 'base' },
            { label = 'Oturub qalx', dict = 'amb@world_human_sit_ups@base', lib = 'base' },
            { label = 'Yerində qaç', dict = 'amb@world_human_jog_standing@base', lib = 'base' },
            { label = 'Yoga', dict = 'amb@world_human_yoga@base', lib = 'base' },
        }
    },
    {
        name = 'diger',
        label = '🎭 Digər',
        items = {
            { label = 'Yerə uzan', scenario = 'WORLD_HUMAN_SUNBATHE' },
            { label = 'Dua et', dict = 'amb@prop_human_praying@male@base', lib = 'base' },
            { label = 'Dərd çək', dict = 'amb@world_human_drunk@male@base', lib = 'base' },
            { label = 'Qəzəblənmə', dict = 'amb@world_human_greeting_police', lib = 'gesture_hello' },
            { label = 'Ağla', dict = 'mp_facial', lib = 'cry_0' },
            { label = 'Gül', dict = 'mp_facial', lib = 'smile_0' },
            { label = 'Yerə otur (düşüncəli)', scenario = 'WORLD_HUMAN_STAND_IMPATIENT' },
        }
    },
}

-- Animasiyanı dayandırmaq üçün istifadə olunan düymə (ESC)
Config.CancelKey = 177  -- BACKSPACE

-- Qeyd: X düyməsi (73) və ya hər hansı hərəkət animasiyanı kəsir
