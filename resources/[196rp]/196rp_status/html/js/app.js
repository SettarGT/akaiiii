const hud = {
    healthFill: document.getElementById('healthFill'),
    armorFill: document.getElementById('armorFill'),
    foodFill: document.getElementById('foodFill'),
    waterFill: document.getElementById('waterFill'),
    energyFill: document.getElementById('energyFill'),
    timeDisplay: document.getElementById('timeDisplay'),
    cashDisplay: document.getElementById('cashDisplay'),
    bankDisplay: document.getElementById('bankDisplay'),
};

let hudVisible = true;

function setFill(el, value, lowThreshold = null) {
    const v = Math.max(0, Math.min(100, value));
    el.style.width = v + '%';
    if (lowThreshold !== null) {
        el.classList.toggle('low', v < lowThreshold);
    }
}

function setHudVisibility(show) {
    hudVisible = show;
    document.body.classList.toggle('hidden', !show);
}

window.addEventListener('message', (event) => {
    const data = event.data;
    if (!data || !data.action) return;

    switch (data.action) {
        case 'showHud':
            setHudVisibility(true);
            break;
        case 'hideHud':
            setHudVisibility(false);
            break;
        case 'updateHud':
            if (data.data.health !== undefined) setFill(hud.healthFill, data.data.health);
            if (data.data.armor !== undefined) setFill(hud.armorFill, data.data.armor);
            if (data.data.food !== undefined) setFill(hud.foodFill, data.data.food, 25);
            if (data.data.water !== undefined) setFill(hud.waterFill, data.data.water, 25);
            if (data.data.energy !== undefined) setFill(hud.energyFill, data.data.energy, 20);
            if (data.data.cash !== undefined) {
                hud.cashDisplay.textContent = '$' + formatNumber(data.data.cash);
            }
            if (data.data.bank !== undefined) {
                hud.bankDisplay.textContent = '$' + formatNumber(data.data.bank);
            }
            break;
        case 'updateTime':
            hud.timeDisplay.textContent = data.data.time || '00:00';
            break;
    }
});

function formatNumber(n) {
    n = Math.round(n || 0);
    return n.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ' ');
}
