const grid = document.getElementById('spawnGrid');

window.addEventListener('message', (event) => {
    const data = event.data || {};
    if (data.action === 'open') {
        render(data.spawns || []);
    }
});

function render(spawns) {
    grid.innerHTML = '';
    spawns.forEach((spawn, index) => {
        const card = document.createElement('div');
        card.className = 'card';
        card.style.animationDelay = (index * 0.05) + 's';

        card.innerHTML = `
            <span class="icon">${spawn.icon || '📍'}</span>
            <div class="name">${spawn.name}</div>
            <div class="desc">${spawn.desc}</div>
            <span class="go">BURAYA GET →</span>
        `;

        card.addEventListener('click', () => {
            fetch(`https://196rp_spawn/selectSpawn`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ id: spawn.id })
            });
        });

        grid.appendChild(card);
    });
}

document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
        fetch(`https://196rp_spawn/close`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({})
        });
    }
});
