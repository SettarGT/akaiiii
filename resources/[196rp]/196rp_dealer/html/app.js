const dealer = document.getElementById('dealer');

function post(action, data) {
    fetch('https://196rp_dealer/' + action, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data || {}),
    });
}

window.addEventListener('message', e => {
    const d = e.data;
    if (!d || !d.action) return;
    if (d.action === 'open') {
        dealer.classList.remove('hidden');
        render(d.vehicles || []);
    }
    if (d.action === 'close') dealer.classList.add('hidden');
});

function render(vehicles) {
    const grid = document.getElementById('grid');
    if (!vehicles.length) {
        grid.innerHTML = '<div class="empty" style="grid-column:1/-1;color:#66738a;text-align:center;padding:40px">Salon hazırda boşdur.</div>';
        return;
    }
    grid.innerHTML = vehicles.map(v => `
      <div class="card">
        <div class="name">${v.label}</div>
        <div class="brand">${v.brand} · ${v.class}</div>
        <div class="price">₣${Number(v.price).toLocaleString('az-AZ')} <small>/ ədəd</small></div>
        <div class="btns">
          <button class="test" onclick="post('testdrive',{model:'${v.model}'})">🏎 Sınaq</button>
          <button class="buy" onclick="buy('${v.model}','${v.label}','${v.price}')">🛒 Al</button>
        </div>
      </div>`).join('');
}

function buy(model, label, price) {
    if (!confirm(`${label} — ₣${Number(price).toLocaleString('az-AZ')}. Alışı təsdiqləyirsiniz?`)) return;
    post('buy', { model });
    setTimeout(() => post('close'), 300);
}

document.getElementById('btn-close').addEventListener('click', () => post('close'));
