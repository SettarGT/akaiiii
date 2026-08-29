// 196 RP - Spawn seçimi NUI

const grid = document.getElementById('spawnGrid');

// Səhifə açılanda GİZLİ olsun — server 'open' göndərəndə görünür, 'close' ilə gizlənir.
// (Əvvəlki versiyada close mesajı səhifəni gizlətmirdi — ekran "yapışıb" qalırdı.)
document.body.style.display = 'none';

window.addEventListener('message', (event) => {
    const data = event.data || {};
    if (data.action === 'open') {
        document.body.style.display = '';
        render(data.spawns || []);
    } else if (data.action === 'close') {
        document.body.style.display = 'none';
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
            document.body.style.display = 'none';
            fetch(`https://196rp_spawn/selectSpawn`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ id: spawn.id })
            });
        });

        grid.appendChild(card);
    });
}

function closeSelf() {
    document.body.style.display = 'none';
    fetch(`https://196rp_spawn/close`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
}

document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') closeSelf();
});

// Ehtiyat: bəzi CEF versiyalarında Escape yalnız keyup-da çatır
document.addEventListener('keyup', (e) => {
    if (e.key === 'Escape') closeSelf();
});
