const atm = document.getElementById('atm');
let mode = 'withdraw';
const quicks = [100, 500, 1000, 5000, 10000];

function post(action, data) {
    fetch('https://196rp_atm/' + action, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data || {}),
    });
}

window.addEventListener('message', e => {
    const d = e.data;
    if (!d || !d.action) return;
    if (d.action === 'open') atm.classList.remove('hidden');
    if (d.action === 'close') atm.classList.add('hidden');
    if (d.action === 'balance') {
        document.getElementById('bank').textContent = '₣' + Number(d.data.bank || 0).toLocaleString('az-AZ');
        document.getElementById('cash').textContent = '₣' + Number(d.data.cash || 0).toLocaleString('az-AZ');
    }
});

document.querySelectorAll('.tab').forEach(t => {
    t.addEventListener('click', () => {
        document.querySelectorAll('.tab').forEach(x => x.classList.remove('active'));
        t.classList.add('active');
        mode = t.dataset.act;
        document.getElementById('transfer-row').classList.toggle('hidden', mode !== 'transfer');
        showMsg('');
    });
});

const quickBox = document.getElementById('quick');
quicks.forEach(q => {
    const b = document.createElement('button');
    b.textContent = '₣' + q.toLocaleString('az-AZ');
    b.onclick = () => { document.getElementById('amount').value = q; };
    quickBox.appendChild(b);
});

function showMsg(t, ok) {
    const m = document.getElementById('msg');
    m.classList.toggle('hidden', !t);
    m.textContent = t;
    m.style.background = ok ? 'rgba(60,190,110,.14)' : 'rgba(247,183,51,.12)';
}

document.getElementById('btn-amount').addEventListener('click', () => {
    const amount = document.getElementById('amount').value;
    if (!amount || Number(amount) <= 0) return showMsg('Məbləğ daxil edin!');
    if (mode === 'withdraw') post('withdraw', { amount });
    else if (mode === 'deposit') post('deposit', { amount });
    else if (mode === 'transfer') {
        const target = document.getElementById('target').value;
        if (!target) return showMsg('Oyunçu ID daxil edin!');
        post('transfer', { target, amount });
    }
    showMsg('Əməliyyat göndərildi...');
});

document.getElementById('btn-close').addEventListener('click', () => post('close'));
