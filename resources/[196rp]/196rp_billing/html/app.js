const bill = document.getElementById('bill');
let remaining = 0;
let timer = null;
let billId = null;

window.addEventListener('message', function (event) {
    const data = event.data;
    if (!data || !data.action) return;

    switch (data.action) {
        case 'show': {
            bill.classList.remove('hidden');
            billId = data.data.id;
            document.getElementById('b-from').textContent = data.data.from || '—';
            document.getElementById('b-reason').textContent = data.data.reason || '—';
            document.getElementById('b-amount').textContent = '₣' + Number(data.data.amount || 0).toLocaleString('az-AZ');
            remaining = data.data.expiry || 300;
            startTimer();
            break;
        }
        case 'hide': {
            bill.classList.add('hidden');
            if (timer) clearInterval(timer);
            break;
        }
    }
});

function startTimer() {
    if (timer) clearInterval(timer);
    timer = setInterval(function () {
        remaining -= 1;
        const m = Math.floor(remaining / 60);
        const s = remaining % 60;
        document.getElementById('b-timer').textContent = m + ':' + (s < 10 ? '0' : '') + s;
        if (remaining <= 0) {
            clearInterval(timer);
            post('decline');
        }
    }, 1000);
}

function post(action) {
    fetch('https://196rp_billing/' + action, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ id: billId }),
    });
}

document.getElementById('btn-accept').addEventListener('click', function () { post('accept'); });
document.getElementById('btn-decline').addEventListener('click', function () { post('decline'); });
