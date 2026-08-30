(() => {
    const panel = document.getElementById('panel');
    const unitEl = document.getElementById('unit');
    const timerEl = document.getElementById('timer');
    const currentEl = document.getElementById('current');
    const stepEl = document.getElementById('step');
    const minEl = document.getElementById('min');
    const bidInput = document.getElementById('bid');
    const submitBtn = document.getElementById('submit');
    const closeBtn = document.getElementById('close');

    let until = 0;
    let minBid = 500;
    let step = 250;

    const fmt = v => '₣' + Number(v || 0).toLocaleString('az-AZ');

    function tick() {
        const left = Math.max(0, Math.ceil((until - Date.now() / 1000)));
        timerEl.textContent = left;
        if (left <= 0) {
            submitBtn.disabled = true;
            clearInterval(window.__auctionTick);
        }
    }

    function post(action, data) {
        fetch(`https://196rp_storage/${action}`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json; charset=UTF-8' },
            body: JSON.stringify(data || {}),
        });
    }

    window.addEventListener('message', (e) => {
        const d = e.data || {};
        if (d.action === 'open') {
            panel.classList.remove('hidden');
            unitEl.textContent = d.data.unit;
            until = d.data.ends;
            minBid = d.data.minBid || 500;
            step = d.data.step || 250;
            stepEl.textContent = fmt(step);
            minEl.textContent = fmt(minBid);
            currentEl.textContent = fmt(d.data.current || 0);
            bidInput.value = minBid;
            bidInput.min = minBid;
            submitBtn.disabled = false;
            clearInterval(window.__auctionTick);
            window.__auctionTick = setInterval(tick, 500);
            tick();
        } else if (d.action === 'update') {
            currentEl.textContent = fmt(d.data.amount || 0);
            until = d.data.ends;
            bidInput.value = (d.data.amount || 0) + step;
        } else if (d.action === 'close') {
            panel.classList.add('hidden');
            clearInterval(window.__auctionTick);
        }
    });

    submitBtn.addEventListener('click', () => {
        const v = Math.floor(Number(bidInput.value || 0));
        if (v > 0) post('bid', { amount: v });
    });
    closeBtn.addEventListener('click', () => post('close'));
    document.addEventListener('keydown', (e) => {
        if (e.key === 'Escape') post('close');
    });
})();
