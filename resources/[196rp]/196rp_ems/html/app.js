const box = document.getElementById('ems');
const xrayEl = document.getElementById('xray');
const surgeryEl = document.getElementById('surgery');

let xrayTarget = 0;
let seq = [];
let symbols = [];
let steps = 5;
let stepTime = 2.5;
let curState = null;

function post(action, data) {
    fetch('https://196rp_ems/' + action, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data || {}),
    });
}

function hideAll() {
    xrayEl.classList.add('hidden');
    surgeryEl.classList.add('hidden');
    box.classList.add('hidden');
}

window.addEventListener('message', e => {
    const d = e.data;
    if (!d || !d.action) return;
    if (d.action === 'hide') { hideAll(); return; }

    box.classList.remove('hidden');
    if (d.action === 'xray') {
        xrayEl.classList.remove('hidden');
        surgeryEl.classList.add('hidden');
        xrayTarget = d.target;
        renderXray(d);
    } else if (d.action === 'surgery') {
        xrayEl.classList.add('hidden');
        surgeryEl.classList.remove('hidden');
        startSurgery(d);
    }
});

function renderXray(d) {
    document.getElementById('xTarget').textContent = d.target || '-';
    document.getElementById('xCrit').textContent = d.critical + '%';
    const grid = document.getElementById('xGrid');
    grid.innerHTML = '';
    (d.zoneMeta || []).forEach(z => {
        const val = Math.floor(d.zones[z.id] || 0);
        const crit = val >= d.critical;
        const card = document.createElement('div');
        card.className = 'zcard' + (crit ? ' crit' : '');
        card.innerHTML = `
            <div class="ztop"><span class="zn">${z.icon} ${z.label}</span><span>${val}%</span></div>
            <div class="zbar"><div class="zfill" style="width:${Math.min(100, val)}%"></div></div>`;
        grid.appendChild(card);
    });
}

document.getElementById('btnXrayClose').addEventListener('click', () => post('close'));
document.getElementById('btnSurgery').addEventListener('click', () => post('startSurgery', { target: xrayTarget }));

function startSurgery(d) {
    symbols = d.symbols || [];
    steps = d.steps || 5;
    stepTime = d.stepTime || 2.5;
    document.getElementById('sTotal').textContent = steps;
    curState = 'show';
    seq = [];
    for (let i = 0; i < steps; i++) seq.push(symbols[Math.floor(Math.random() * symbols.length)]);

    const show = document.getElementById('sShow');
    show.innerHTML = '';
    seq.forEach(s => {
        const el = document.createElement('div');
        el.className = 'sym';
        el.textContent = s;
        show.appendChild(el);
    });

    // input düymələri
    const input = document.getElementById('sInput');
    input.innerHTML = '';
    symbols.forEach(s => {
        const b = document.createElement('button');
        b.className = 'sbtn';
        b.textContent = s;
        b.onclick = () => {
            b.classList.toggle('sel');
            setTimeout(() => b.classList.remove('sel'), 180);
            curInput.push(s);
            curIdx++;
            if (curIdx >= seq.length) check();
        };
        input.appendChild(b);
    });

    curInput = [];
    curIdx = 0;
    setTimeout(() => {
        document.getElementById('sShow').innerHTML = '';
        document.getElementById('sStage').innerHTML = 'Addım ' + steps + ' / ' + steps + ' — Təkrarla';
    }, stepTime * 1000);
}

let curInput = [];
let curIdx = 0;

function check() {
    const ok = seq.every((s, i) => s === curInput[i]);
    document.getElementById('sStage').innerHTML = ok ? '✅ Uğurlu!' : '❌ Səhv — yenidən cəhd';
    setTimeout(() => post('surgeryDone', { target: xrayTarget, success: ok }), ok ? 600 : 1400);
}

document.addEventListener('keydown', ev => {
    if (ev.key === 'Escape') {
        if (!surgeryEl.classList.contains('hidden')) post('close');
        else post('close');
    }
});
