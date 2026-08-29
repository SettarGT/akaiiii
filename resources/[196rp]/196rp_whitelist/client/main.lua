local QBCore = exports['qb-core']:GetCoreObject()

local function openApplication()
    local dialog = exports['qb-input']:ShowInput({
        header = Config.Text.apply_title,
        submitText = Config.Text.apply_submit,
        inputs = {
            { type = 'text', isRequired = true, name = 'firstname', text = 'Ad' },
            { type = 'text', isRequired = true, name = 'lastname', text = 'Soyad' },
            { type = 'number', isRequired = true, name = 'age', text = 'Yaş' },
            { type = 'text', isRequired = true, name = 'discord', text = 'Discord adınız (Nümunə: 196RP#0001)' },
            { type = 'text', isRequired = true, name = 'rpexp', text = 'RP təcrübəniz (serverlər, illər)' },
            { type = 'text', isRequired = false, name = 'reason', text = 'Niyə 196 RP? (istəyə bağlı)' },
        }
    })
    if not dialog then return end
    if dialog.age == nil or tonumber(dialog.age) < Config.MinAge then
        QBCore.Functions.Notify(('Müraciət üçün minimum yaş %d-dir.'):format(Config.MinAge), 'error')
        return
    end
    TriggerServerEvent('196rp_whitelist:apply', {
        firstname = dialog.firstname,
        lastname = dialog.lastname,
        age = tonumber(dialog.age),
        discord = dialog.discord,
        rpexp = dialog.rpexp,
        reason = dialog.reason or '-',
    })
end

RegisterCommand('muraciet', function() openApplication() end, false)

RegisterKeyMapping('muraciet', 'Whitelist müraciəti', 'keyboard', '')

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    -- Müraciət həmişə açıqdır; OpenRegistration=false olsa belə
    -- yalnız qəbul edilmiş oyunçular daxil olur.
    if not Config.WhitelistEnabled or Config.OpenRegistration then
        QBCore.Functions.Notify('Xoş gəlmisiniz!', 'success')
    end
end)
