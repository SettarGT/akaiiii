const panel = document.getElementById('panel');

function post(action) {
    fetch('https://196rp_hybrid/' + action, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({}),
    });
}

window.addEventListener('message', e => {
    const d = e.data;
    if (!d || !d.action) return;
    if (d.action === 'open') panel.classList.remove('hidden');
    if (d.action === 'status') render(d.list || []);
});

function render(list) {
    const grid = document.getElementById('grid');
    grid.innerHTML = list.map(j => `
      <div class="pn-card">
        <div class="top">
          <span class="icon">${j.icon}</span>
          <span class="label">${j.label}</span>
          <span class="count" style="color:${j.count > 0 ? j.color : '#55637a'}">${j.count}</span>
        </div>
        ${j.count > 0
            ? `<div class="names">${j.onDuty.map(n => '• ' + n).join('<br>')}</div>`
            : '<div class="off">Növbətçi yoxdur</div>'}
      </div>`).join('');
}

document.getElementById('btn-close').addEventListener('click', () => post('close'));
