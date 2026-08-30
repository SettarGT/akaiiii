const cryptoBox = document.getElementById('crypto');
let side = 'buy';
let lastPrice = 0;

function post(action, data) {
    fetch('https://196rp_crypto/' + action, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data || {}),
    });
}

window.addEventListener('message', e => {
    const d = e.data;
    if (!d || !d.action) return;
    if (d.action === 'open') {
        cryptoBox.classList.remove('hidden');
        render(d.data);
    }
});

function render(data) {
    if (!data) return;
    lastPrice = data.price;
    document.getElementById('price').textContent = '₣' + Number(data.price).toLocaleString('az-AZ');
    document.getElementById('coins').textContent = Number(data.balance).toFixed(4);
    document.getElementById('cash').textContent = '₣' + Number(data.cash).toLocaleString('az-AZ');
    document.getElementById('bank').textContent = '₣' + Number(data.bank).toLocaleString('az-AZ');

    const hist = data.history || [];
    const delta = document.getElementById('delta');
    if (hist.length >= 2) {
        const first = hist[0].p, last = hist[hist.length - 1].p;
        const pct = ((last - first) / first * 100).toFixed(2);
        delta.textContent = (Number(pct) >= 0 ? '▲ +' : '▼ ') + pct + '%';
        delta.classList.toggle('neg', Number(pct) < 0);
        drawChart(hist);
    }
}

function drawChart(hist) {
    const svg = document.getElementById('chart');
    const w = 600, h = 190, pad = 12;
    let min = Infinity, max = -Infinity;
    hist.forEach(p => { if (p.p < min) min = p.p; if (p.p > max) max = p.p; });
    if (max === min) { max += 1; min -= 1; }
    const xs = i => pad + i * ((w - pad * 2) / (hist.length - 1));
    const ys = v => h - pad - ((v - min) / (max - min)) * (h - pad * 2);

    const up = hist[hist.length - 1].p >= hist[0].p;
    const color = up ? '#46dcb4' : '#ff5f5f';
    const pts = hist.map((p, i) => `${xs(i).toFixed(1)},${ys(p.p).toFixed(1)}`).join(' ');
    const area = `M${xs(0)},${ys(hist[0].p)} ${pts.split(' ').map((v, i) => `L${v}`).join(' ')} L${xs(hist.length - 1)},${h - pad} L${xs(0)},${h - pad} Z`;

    svg.innerHTML = `
      <defs>
        <linearGradient id="g" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stop-color="${color}" stop-opacity="0.35"/>
          <stop offset="100%" stop-color="${color}" stop-opacity="0"/>
        </linearGradient>
      </defs>
      <path d="${area}" fill="url(#g)" stroke="none"/>
      <polyline points="${pts}" fill="none" stroke="${color}" stroke-width="2.5" stroke-linejoin="round"/>
      <circle cx="${xs(hist.length - 1)}" cy="${ys(hist[hist.length - 1].p)}" r="4" fill="${color}"/>
    `;
}

document.querySelectorAll('.t-tab').forEach(t => {
    t.addEventListener('click', () => {
        document.querySelectorAll('.t-tab').forEach(x => x.classList.remove('active'));
        t.classList.add('active');
        side = t.dataset.side;
    });
});

document.getElementById('btn-go').addEventListener('click', () => {
    const amount = document.getElementById('amount').value;
    if (!amount || Number(amount) <= 0) return;
    post(side === 'buy' ? 'buy' : 'sell', { amount });
});

document.getElementById('btn-close').addEventListener('click', () => post('close'));
