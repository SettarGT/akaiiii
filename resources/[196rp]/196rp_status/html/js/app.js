const hud = {
    healthFill: document.getElementById('healthFill'),
    healthValue: document.getElementById('healthValue'),
    healthBlock: document.getElementById('healthBlock'),
    armorFill: document.getElementById('armorFill'),
    armorValue: document.getElementById('armorValue'),
    armorBlock: document.getElementById('armorBlock'),
    foodFill: document.getElementById('foodFill'),
    foodPct: document.getElementById('foodPct'),
    foodPill: document.getElementById('foodPill'),
    waterFill: document.getElementById('waterFill'),
    waterPct: document.getElementById('waterPct'),
    waterPill: document.getElementById('waterPill'),
    energyFill: document.getElementById('energyFill'),
    energyPct: document.getElementById('energyPct'),
    energyPill: document.getElementById('energyPill'),
    timeDisplay: document.getElementById('timeDisplay'),
    cashDisplay: document.getElementById('cashDisplay'),
    bankDisplay: document.getElementById('bankDisplay'),
};

let hudVisible = true;

function setFill(el, value, lowThreshold = null, pillEl = null, pctEl = null) {
    const v = Math.max(0, Math.min(100, Math.round(value)));
    el.style.width = v + '%';
    if (pctEl) pctEl.textContent = v;
    if (pillEl && lowThreshold !== null) {
        pillEl.classList.toggle('low', v < lowThreshold);
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
        case 'updateHud': {
            const d = data.data || {};
            if (d.health !== undefined) {
                setFill(hud.healthFill, d.health);
                hud.healthValue.textContent = Math.round(d.health);
                hud.healthBlock.classList.toggle('critical', d.health < 30);
            }
            if (d.armor !== undefined) {
                setFill(hud.armorFill, d.armor);
                hud.armorValue.textContent = Math.round(d.armor);
            }
            if (d.food !== undefined) setFill(hud.foodFill, d.food, 25, hud.foodPill, hud.foodPct);
            if (d.water !== undefined) setFill(hud.waterFill, d.water, 25, hud.waterPill, hud.waterPct);
            if (d.energy !== undefined) setFill(hud.energyFill, d.energy, 20, hud.energyPill, hud.energyPct);
            if (d.cash !== undefined) hud.cashDisplay.textContent = '$' + formatNumber(d.cash);
            if (d.bank !== undefined) hud.bankDisplay.textContent = '$' + formatNumber(d.bank);
            break;
        }
        case 'updateTime':
            hud.timeDisplay.textContent = data.data.time || '00:00';
            break;
    }
});

function formatNumber(n) {
    n = Math.round(n || 0);
    return n.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ' ');
}
