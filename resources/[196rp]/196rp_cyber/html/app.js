const hackBox = document.getElementById('hack');
const seqBox = document.getElementById('seq');
const btnsBox = document.getElementById('btns');
const symbols = ['⬛', '▲', '●', '◆', '■', '★'];
let sequence = [];
let playerInput = 0;
let chance = 45;

function post(action, data) {
    fetch('https://196rp_cyber/' + action, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data || {}),
    });
}

window.addEventListener('message', e => {
    const d = e.data;
    if (!d || !d.action) return;
    if (d.action === 'open') {
        chance = d.chance || 45;
        document.getElementById('chance').textContent = chance + '%';
        hackBox.classList.remove('hidden');
        startGame();
    }
});

function startGame() {
    sequence = [];
    playerInput = 0;
    for (let i = 0; i < 5; i++) sequence.push(symbols[Math.floor(Math.random() * symbols.length)]);
    seqBox.innerHTML = sequence.map(() => '<div>?</div>').join('');
    btnsBox.innerHTML = '';
    symbols.forEach(s => {
        const b = document.createElement('button');
        b.textContent = s;
        b.onclick = () => press(s, b);
        btnsBox.appendChild(b);
    });
    showSeq();
}

function showSeq() {
    let i = 0;
    const cells = seqBox.children;
    const iv = setInterval(() => {
        if (i >= sequence.length) { clearInterval(iv); return; }
        cells[i].textContent = sequence[i];
        cells[i].classList.add('lit');
        setTimeout(() => cells[i].classList.remove('lit'), 450);
        i++;
        if (i === sequence.length) {
            setTimeout(() => {
                for (let c = 0; c < cells.length; c++) cells[c].textContent = '?';
                enableInput(true);
            }, 700);
        }
    }, 650);
}

function enableInput(on) {
    [...btnsBox.children].forEach(b => { b.disabled = !on; });
}

function press(sym, btn) {
    enableInput(false);
    const cells = seqBox.children;
    if (sym === sequence[playerInput]) {
        cells[playerInput].textContent = sym;
        cells[playerInput].classList.add('lit');
        playerInput++;
        if (playerInput >= sequence.length) {
            finish(true);
        } else {
            enableInput(true);
        }
    } else {
        btn.classList.add('wrong');
        setTimeout(() => btn.classList.remove('wrong'), 350);
        finish(false);
    }
}

function finish(success) {
    // Server şansı da nəticəyə təsir edir (anti-cheat)
    const roll = Math.random() * 100;
    const final = success && roll < chance;
    document.getElementById('msg').textContent = final
        ? 'Giriş uğurlu... Həmrəy serverlərə əlçatıldı.'
        : 'Giriş rədd edildi... İzlər silinir.';
    setTimeout(() => {
        post('result', { success: final });
        hackBox.classList.add('hidden');
    }, 900);
}
