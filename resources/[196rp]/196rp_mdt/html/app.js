const mdt = document.getElementById('mdt');
let currentTarget = null;

function post(action, data, cb) {
    fetch('https://196rp_mdt/' + action, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data || {}),
    }).then(r => r.json()).then(cb).catch(() => cb && cb({}));
}

window.addEventListener('message', e => {
    if (e.data && e.data.action === 'open') mdt.classList.remove('hidden');
    if (e.data && e.data.action === 'close') mdt.classList.add('hidden');
});

document.getElementById('btn-close').addEventListener('click', () => post('close'));

// Tablar
document.querySelectorAll('.tab').forEach(tab => {
    tab.addEventListener('click', () => {
        document.querySelectorAll('.tab').forEach(t => t.classList.remove('active'));
        tab.classList.add('active');
        document.querySelectorAll('.page').forEach(p => p.classList.remove('active'));
        document.getElementById('page-' + tab.dataset.tab).classList.add('active');
    });
});

// ── Oyunçu axtarışı ──
document.getElementById('btn-search').addEventListener('click', () => doSearch());
document.getElementById('search-input').addEventListener('keydown', e => { if (e.key === 'Enter') doSearch(); });

function doSearch() {
    const q = document.getElementById('search-input').value;
    post('searchPlayer', { query: q }, results => {
        const box = document.getElementById('search-results');
        if (!results || !results.length) {
            box.innerHTML = '<div class="empty">Nəticə tapılmadı.</div>';
            return;
        }
        box.innerHTML = results.map(p => `
          <div class="row">
            <div class="grow">
              <b>${p.name}</b> <span class="chip">${p.citizenid}</span>
              <div class="sub">ID: ${p.source} · 📱 ${p.phone} · İş: ${p.job} · 💵 ₣${Number(p.cash).toLocaleString('az-AZ')} / ₣${Number(p.bank).toLocaleString('az-AZ')}</div>
            </div>
            <button class="mini-btn blue" onclick="showRecords('${p.citizenid}','${p.name}')">📋 Qeydlər</button>
            <button class="mini-btn gold" onclick="openFine(${p.source},'${p.name}')">⚖️ Cərimə</button>
          </div>`).join('');
    });
}

function showRecords(citizenid, name) {
    post('getRecords', { citizenid }, records => {
        document.querySelector('.tab[data-tab="records"]').click();
        document.getElementById('records-info').textContent = `📋 ${name} (${citizenid}) — qeydiyyat tarixçəsi`;
        const box = document.getElementById('records-results');
        if (!records || !records.length) {
            box.innerHTML = '<div class="empty">Bu şəxsin qeydləri yoxdur.</div>';
            return;
        }
        box.innerHTML = `<table>
          <tr><th>Vaxt</th><th>Növ</th><th>Başlıq</th><th>Təfərrüat</th><th>Ofiser</th><th>Cərimə</th></tr>
          ${records.map(r => `<tr>
            <td>${(r.created_at || '').slice(0, 16)}</td>
            <td>${r.type}</td>
            <td>${r.title}</td>
            <td>${r.details || ''}</td>
            <td>${r.officer_name || ''}</td>
            <td>${Number(r.fine_amount || 0) > 0 ? '₣' + Number(r.fine_amount).toLocaleString('az-AZ') : '—'}</td>
          </tr>`).join('')}</table>`;
    });
}

// ── Cərimə modal ──
const presets = [
  ['Sürət həddi', 500], ['Qırmızı işıq', 750], ['Yanlış park', 400],
  ['Təhlükəsizlik kəməri', 350], ['Alkoqol vəziyyəti', 1500],
  ['Qanunsuz silah', 3000], ['Narkotik', 5000], ['Polisə müqavimət', 2500],
  ['Maşın oğurluğu', 4000], ['Xuliqanlıq', 2000],
];
const sel = document.getElementById('fine-preset');
presets.forEach(([k, v]) => {
    const o = document.createElement('option');
    o.value = k; o.dataset.amount = v; o.textContent = `${k} — ₣${v}`;
    sel.appendChild(o);
});
sel.addEventListener('change', () => {
    const opt = sel.options[sel.selectedIndex];
    if (opt.dataset.amount) document.getElementById('fine-amount').value = opt.dataset.amount;
});

function openFine(target, name) {
    currentTarget = target;
    document.getElementById('fine-target').textContent = `Hədəf: ${name} (ID: ${target})`;
    document.getElementById('fine-modal').classList.remove('hidden');
}
document.getElementById('fine-cancel').addEventListener('click', () => {
    document.getElementById('fine-modal').classList.add('hidden');
});
document.getElementById('fine-confirm').addEventListener('click', () => {
    const amount = document.getElementById('fine-amount').value;
    const reason = document.getElementById('fine-reason').value || 'Cərimə';
    if (!currentTarget) return;
    post('addFine', { target: currentTarget, amount, reason }, () => {
        document.getElementById('fine-modal').classList.add('hidden');
        doSearch();
    });
});

// ── Nəqliyyat ──
document.getElementById('btn-plate').addEventListener('click', () => doPlate());
document.getElementById('plate-input').addEventListener('keydown', e => { if (e.key === 'Enter') doPlate(); });

function doPlate() {
    const q = document.getElementById('plate-input').value;
    post('searchVehicle', { query: q }, results => {
        const box = document.getElementById('vehicle-results');
        if (!results || !results.length) {
            box.innerHTML = '<div class="empty">Bu nömrə ilə nəqliyyat tapılmadı.</div>';
            return;
        }
        box.innerHTML = `<table>
          <tr><th>Nömrə</th><th>Model</th><th>Sahibi</th><th>Qaraj</th><th>Status</th></tr>
          ${results.map(v => `<tr>
            <td><b>${v.plate}</b></td>
            <td>${v.vehicle}</td>
            <td>${v.owner_name || v.owner}</td>
            <td>${v.garage || '—'}</td>
            <td>${Number(v.state) === 1 ? '<span class="chip green">Bağlı/Park</span>' : '<span class="chip red">Götürülüb</span>'}</td>
          </tr>`).join('')}</table>`;
    });
}
