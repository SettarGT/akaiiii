const metro = document.getElementById('metro');
let targetId = '';

function post(action, data) {
    fetch('https://196rp_metro/' + action, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data || {}),
    });
}

window.addEventListener('message', e => {
    const d = e.data;
    if (!d || !d.action) return;
    if (d.action === 'ride') {
        metro.classList.remove('hidden');
        runRide(d.id || '', d.label, d.seconds || 25);
    }
    if (d.action === 'arrive') metro.classList.add('hidden');
});

function runRide(id, label, seconds) {
    targetId = id || '';
    document.getElementById('route').innerHTML = '196 METRO → <b>' + label + '</b>';
    const dots = document.getElementById('dots');
    dots.innerHTML = Array.from({ length: 8 }, () => '<span></span>').join('');
    const bar = document.getElementById('bar');
    const train = document.getElementById('train');

    // 8 stansiya keçid animasiyası
    let step = 0;
    const stepMs = (seconds * 1000) / 8;
    const iv = setInterval(() => {
        step++;
        const spans = dots.children;
        for (let i = 0; i < step && i < spans.length; i++) spans[i].classList.add('pass');
        train.style.left = (4 + step * 11.5) + '%';
        bar.style.width = (step / 8 * 100) + '%';
        if (step >= 8) {
            clearInterval(iv);
            setTimeout(() => {
                post('done', { target: targetId });
            }, 700);
        }
    }, stepMs);
}
