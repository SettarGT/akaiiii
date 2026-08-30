const league = document.getElementById('league');

function post(action) {
    fetch('https://196rp_racing/' + action, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({}),
    });
}

window.addEventListener('message', e => {
    const d = e.data;
    if (!d || !d.action) return;
    if (d.action === 'open') {
        league.classList.remove('hidden');
        render(d.standings || []);
    }
    if (d.action === 'close') league.classList.add('hidden');
});

function render(list) {
    const podium = document.getElementById('podium');
    const rows = document.getElementById('rows');

    if (!list.length) {
        podium.innerHTML = '';
        rows.innerHTML = '<tr><td colspan="4" class="empty">Hələ heç kim yarış bitirməyib. İlk yarışı sən qazan!</td></tr>';
        return;
    }

    const top3 = list.slice(0, 3);
    const medals = ['🥇', '🥈', '🥉'];
    podium.innerHTML = top3.map((p, i) => `
      <div class="pod ${i === 1 ? 'silver' : i === 2 ? 'bronze' : ''}">
        <div class="rank">${medals[i]} #${i + 1}</div>
        <div class="name">${p.name}</div>
        <div class="pts">${p.points} xal</div>
      </div>`).join('');

    rows.innerHTML = list.slice(0, 20).map((p, i) => `
      <tr>
        <td>${i + 1}</td>
        <td><b>${p.name}</b></td>
        <td>${p.cid}</td>
        <td class="points">${p.points}</td>
      </tr>`).join('');
}

document.getElementById('btn-close').addEventListener('click', () => post('close'));
