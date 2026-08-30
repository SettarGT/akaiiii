local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('196rp_family:client:proposal', function(data)
    local icon = data.kind == 'ck' and 'fas fa-skull' or 'fas fa-ring'
    local header = data.kind == 'ck' and '☠️ CK TƏKLİFİ' or '💍 Evlilik Təklifi'
    local menu = {
        { header = header, isMenuHeader = true, icon = icon },
        { header = data.name, txt = data.kind == 'ck' and 'Diqqət: karakteriniz SİLİNƏCƏK!' or ('Haqqı: ₣%d'):format(data.price), icon = icon },
        { header = '✅ Qəbul et', icon = 'fas fa-check', params = { accept = true } },
        { header = '❌ İmtina et', icon = 'fas fa-times', params = { accept = false } },
    }
    exports['qb-menu']:openMenu(menu, function(selected)
        if not selected or not selected.params then return end
        TriggerServerEvent('196rp_family:server:confirm', selected.params.accept)
    end)
end)
