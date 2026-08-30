const el = document.getElementById('radar');

window.addEventListener('message', e => {
    const d = e.data;
    if (!d || !d.action) return;
    if (d.action === 'show') el.classList.remove('hidden');
    if (d.action === 'hide') el.classList.add('hidden');
    if (d.action === 'update') {
        document.getElementById('speed').textContent = d.speed || '0';
        document.getElementById('plate').textContent = d.plate || '———';
        document.getElementById('model').textContent = d.model || '—';
        el.classList.toggle('warn', (d.speed || 0) > 60);
    }
    if (d.action === 'plate') {
        // plate skan nəticəsi ekranda 3 san görünsün
        document.getElementById('plate').textContent = d.plate || '———';
        document.getElementById('model').textContent = d.owner ? ('Sahib: ' + d.owner) : '—';
    }
});
