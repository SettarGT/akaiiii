const panel = document.getElementById('panel');

function post(action, data) {
    fetch('https://196rp_dispatch/' + action, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data || {}),
    });
}

function fmtTime(ts) {
    const d = new Date(ts * 1000);
    return d.toLocaleTimeString('az-AZ', { hour: '2-digit', minute: '2-digit' });
}

window.addEventListener('message', e => {
    const d = e.data;
    if (!d || !d.action) return;
    if (d.action === 'open') panel.classList.remove('hidden');
    if (d.action === 'hide') panel.classList.add('hidden');
    if (d.action === 'update') render(d.list || []);
});

function render(list) {
    const box = document.getElementById('list');
    const empty = document.getElementById('empty');
    box.innerHTML = '';
    empty.classList.toggle('hidden', list.length > 0);
    list.forEach(c => {
        const el = document.createElement('div');
        el.className = 'call' + (c.status === 'accepted' ? ' accepted' : '');
        const st = c.status === 'accepted' ? ('QƏBUL: ' + (c.acceptedBy || '?')) : 'YENİ';
        el.innerHTML = `
            <div class="call-top">
                <span class="call-id">ZƏNG #${c.id}</span>
                <span class="call-status ${c.status}">${st}</span>
            </div>
            <div class="call-msg">${c.message}</div>
            <div class="call-meta">👤 ${c.caller} · 🕐 ${fmtTime(c.created)}</div>
            <div class="call-btns">
                ${c.status === 'new' ? '<button class="b-accept" data-a="accept">✔ Qəbul et</button>' : ''}
                <button class="b-done" data-a="done">✅ Bitdi</button>
            </div>`;
        box.appendChild(el);
        el.querySelectorAll('button').forEach(b => {
            b.addEventListener('click', () => post(b.dataset.a, { id: c.id }));
        });
    });
}

document.getElementById('close').addEventListener('click', () => post('close'));
document.addEventListener('keydown', ev => {
    if (ev.key === 'Escape' && !panel.classList.contains('hidden')) post('close');
});
