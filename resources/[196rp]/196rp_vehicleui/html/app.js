const radial = document.getElementById('radial');

window.addEventListener('message', function (event) {
    const data = event.data;
    if (!data || !data.action) return;

    switch (data.action) {
        case 'open':
            radial.classList.remove('hidden');
            break;
        case 'close':
            radial.classList.add('hidden');
            break;
        case 'refresh':
            if (data.data) {
                document.getElementById('plate').textContent = data.data.plate || '---';
                document.getElementById('engine-state').textContent =
                    'Mühərrik: ' + (data.data.engine ? 'ON' : 'OFF');
                document.getElementById('lock-state').textContent =
                    'Kilid: ' + (data.data.locked ? 'Bağlı' : 'Açıq');
            }
            break;
    }
});

document.querySelectorAll('.item').forEach(function (btn) {
    btn.addEventListener('click', function () {
        const action = btn.getAttribute('data-action');
        if (action === 'close') {
            fetch('https://196rp_vehicleui/close', { method: 'POST' });
            return;
        }
        fetch('https://196rp_vehicleui/action', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ action: action }),
        });
    });
});

document.addEventListener('keyup', function (e) {
    if (e.key === 'Escape') {
        fetch('https://196rp_vehicleui/close', { method: 'POST' });
    }
});
