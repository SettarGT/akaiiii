const el = document.getElementById('social');
let curApp = 'twatter';
let feed = [];

function post(action, data) {
    fetch('https://196rp_social/' + action, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data || {}),
    });
}

function fmt(ts) {
    const d = new Date(ts * 1000);
    return d.toLocaleString('az-AZ', { day: '2-digit', month: '2-digit', hour: '2-digit', minute: '2-digit' });
}

function render() {
    const box = document.getElementById('feed');
    const empty = document.getElementById('empty');
    box.innerHTML = '';
    empty.classList.toggle('hidden', feed.length > 0);
    feed.forEach(p => {
        const item = document.createElement('div');
        item.className = 'post';
        item.innerHTML = `
            <div class="post-top">
                <span class="post-author">${curApp === 'gram' ? '📸 ' : '🐦 '}${p.author}</span>
                <span>${fmt(p.time)}</span>
            </div>
            <div class="post-text">${p.text}</div>
            <button class="post-like">♥ ${p.likes || 0}</button>`;
        item.querySelector('.post-like').addEventListener('click', () => post('like', { app: curApp, id: p.id }));
        box.appendChild(item);
    });
}

window.addEventListener('message', e => {
    const d = e.data;
    if (!d || !d.action) return;
    if (d.action === 'open') el.classList.remove('hidden');
    if (d.action === 'hide') el.classList.add('hidden');
    if (d.action === 'feed') {
        curApp = d.app;
        feed = d.feed || [];
        render();
    }
});

document.querySelectorAll('.tab').forEach(t => {
    t.addEventListener('click', () => {
        document.querySelectorAll('.tab').forEach(x => x.classList.remove('active'));
        t.classList.add('active');
        post('switch', { app: t.dataset.app });
    });
});

document.getElementById('close').addEventListener('click', () => post('close'));
document.addEventListener('keydown', ev => {
    if (ev.key === 'Escape' && !el.classList.contains('hidden')) post('close');
});
