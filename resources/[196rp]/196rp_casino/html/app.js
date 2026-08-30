const casino = document.getElementById('casino');
let game = 'roulette';

function post(action, data) {
    fetch('https://196rp_casino/' + action, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data || {}),
    });
}
function showMsg(t) {
    const m = document.getElementById('msg');
    m.textContent = t || '';
    m.classList.toggle('hidden', !t);
}

window.addEventListener('message', e => {
    const d = e.data;
    if (!d || !d.action) return;
    if (d.action === 'open') casino.classList.remove('hidden');
    if (d.action === 'close') casino.classList.add('hidden');
    if (d.action === 'balance') document.getElementById('cash').textContent = '₣' + Number(d.cash || 0).toLocaleString('az-AZ');
    if (d.action === 'rouletteResult') rouletteResult(d.data);
    if (d.action === 'diceResult') diceResult(d.data);
    if (d.action === 'slotsResult') slotsResult(d.data);
});

// Tablar
document.querySelectorAll('.tab').forEach(t => {
    t.addEventListener('click', () => {
        document.querySelectorAll('.tab').forEach(x => x.classList.remove('active'));
        t.classList.add('active');
        document.querySelectorAll('.game').forEach(g => g.classList.remove('active'));
        document.getElementById('game-' + t.dataset.game).classList.add('active');
        game = t.dataset.game;
    });
});

// Rulet tip dəyişəndə dəyər seçimini yenilə
const rType = document.getElementById('r-type');
const rValue = document.getElementById('r-value');
const valueOpts = {
    color: [['qirmizi','🔴 Qırmızı'],['qara','⚫ Qara'],['yashil','🟢 Yaşıl']],
    evenodd: [['cute','Cüt'],['tek','Tək']],
    number: Array.from({length: 37}, (_, i) => [String(i), String(i)]),
};
rType.addEventListener('change', () => {
    rValue.innerHTML = '';
    valueOpts[rType.value].forEach(([v, l]) => {
        const o = document.createElement('option');
        o.value = v; o.textContent = l; rValue.appendChild(o);
    });
});

function rouletteResult(d) {
    const wheel = document.getElementById('wheel');
    const res = document.getElementById('r-result');
    wheel.classList.add('spin');
    setTimeout(() => {
        wheel.classList.remove('spin');
        wheel.textContent = d.number;
        wheel.style.background = d.color === 'qirmizi'
            ? 'conic-gradient(#e63c78 0deg 360deg, #e63c78 0deg 360deg)'
            : d.color === 'qara'
            ? 'conic-gradient(#222 0deg 360deg, #222 0deg 360deg)'
            : 'conic-gradient(#22c55e 0deg 360deg, #22c55e 0deg 360deg)';
    }, 2250);
    res.classList.toggle('hidden', false);
    res.classList.toggle('lose', !d.won);
    res.textContent = d.won ? `🎉 UDUŞ! +₣${Number(d.win).toLocaleString('az-AZ')}` : `Sonuc: ${d.number} — uduzdunuz (-₣${Number(d.bet).toLocaleString('az-AZ')})`;
    setTimeout(() => post('getBalance'), 400);
}

function diceResult(d) {
    const res = document.getElementById('d-result');
    document.getElementById('d-dice').innerHTML = `<div class="die">${d.roll}</div>`;
    res.classList.toggle('hidden', false);
    res.classList.toggle('lose', !d.won);
    res.textContent = d.won ? `🎉 UDUŞ! +₣${Number(d.win).toLocaleString('az-AZ')}` : `Zar: ${d.roll} — uduzdunuz (-₣${Number(d.bet).toLocaleString('az-AZ')})`;
}

function slotsResult(d) {
    const res = document.getElementById('s-result');
    const reels = document.querySelectorAll('#s-reels .reel');
    reels.forEach(r => r.classList.add('rolling'));
    let i = 0;
    const iv = setInterval(() => {
        if (i >= d.symbols.length) { clearInterval(iv); return; }
        reels[i].textContent = d.symbols[i];
        reels[i].classList.remove('rolling');
        i++;
    }, 350);
    res.classList.toggle('hidden', false);
    res.classList.toggle('lose', !d.won);
    res.textContent = d.won ? `🎰 UDUŞ! +₣${Number(d.win).toLocaleString('az-AZ')}` : `Slot: uduzdunuz (-₣${Number(d.bet).toLocaleString('az-AZ')})`;
}

document.getElementById('r-go').addEventListener('click', () => post('roulette', {
    betType: rType.value, betValue: rValue.value, amount: document.getElementById('r-bet').value,
}));
document.getElementById('d-go').addEventListener('click', () => post('dice', {
    choice: document.getElementById('d-choice').value, amount: document.getElementById('d-bet').value,
}));
document.getElementById('s-go').addEventListener('click', () => post('slots', {
    amount: document.getElementById('s-bet').value,
}));
document.getElementById('btn-close').addEventListener('click', () => post('close'));

// Balans yeniləmə (uduşdan sonra server yenidən göndərir)
// server tərəfdən 196rp_casino:server:getBalance client-ə müraciət edilir
