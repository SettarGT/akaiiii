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
    if (d.action === 'blackjackState') {
        bjMine = d.data.player || [];
        bjDealer = (d.data.dealer || []).slice();
        bjDealer.push({ back: true });
        bjActive = true;
        bjRender();
        bjOut('');
    }
    if (d.action === 'blackjackResult') {
        bjMine = d.data.player || [];
        bjDealer = d.data.dealer || [];
        bjActive = false;
        bjRender();
        const r = d.data.result;
        const txt = r === 'win' ? '🎉 Qazandınız!' : r === 'blackjack' ? '🃏 BLACKJACK! Qazandınız!' : r === 'push' ? '🤝 Bərabərə — mərc geri' : '💀 Uduzdunuz';
        bjOut(txt);
        post('getBalance');
    }
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

// ── BLACKJACK (21) ──
let bjMine = [], bjDealer = [], bjActive = false;

function bjCard(c) {
    if (!c) return '';
    if (c.back) return '<div class="card back">?</div>';
    const red = (c.suit === '♥' || c.suit === '♦') ? ' red' : '';
    return '<div class="card' + red + '"><span class="cv">' + c.label + '</span><span class="cs">' + c.suit + '</span></div>';
}

function bjSum(hand) {
    let s = 0, aces = 0;
    hand.forEach(c => { if (c.val) { s += c.val; if (c.label === 'A') aces++; } });
    while (s > 21 && aces > 0) { s -= 10; aces--; }
    return s;
}

function bjRender() {
    document.getElementById('bj-mine').innerHTML = bjMine.map(bjCard).join('');
    document.getElementById('bj-dealer').innerHTML = bjDealer.map(bjCard).join('');
    document.getElementById('bj-my-sum').textContent = bjSum(bjMine);
    const ds = bjDealer.filter(c => c.val).length ? bjSum(bjDealer.filter(c => c.val)) : 0;
    document.getElementById('bj-dealer-sum').textContent = ds;
    document.getElementById('bj-hit').classList.toggle('disabled', !bjActive);
    document.getElementById('bj-stand').classList.toggle('disabled', !bjActive);
}

function bjOut(txt) {
    const r = document.getElementById('bj-result');
    if (!r) return;
    r.textContent = txt;
    r.classList.toggle('hidden', !txt);
    if (txt) setTimeout(() => r.classList.add('hidden'), 3500);
}

document.getElementById('bj-start').addEventListener('click', () => {
    const amt = Math.floor(+(document.getElementById('bj-bet').value || 0));
    if (amt < 100) { showMsg('Minimum mərc ₣100'); return; }
    showMsg('');
    bjMine = []; bjDealer = []; bjActive = true;
    post('blackjack', { action: 'start', amount: amt });
});
document.getElementById('bj-hit').addEventListener('click', () => { if (bjActive) post('blackjack', { action: 'hit' }); });
document.getElementById('bj-stand').addEventListener('click', () => { if (bjActive) post('blackjack', { action: 'stand' }); });
