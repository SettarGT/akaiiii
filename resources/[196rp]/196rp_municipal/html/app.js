const exam = document.getElementById('exam');
const card = document.getElementById('card');

let questions = [];
let current = 0;
let answers = {};

window.addEventListener('message', function (event) {
    const data = event.data;
    if (!data || !data.action) return;

    switch (data.action) {
        case 'exam': {
            questions = data.data.questions || [];
            current = 0;
            answers = {};
            exam.classList.remove('hidden');
            card.classList.add('hidden');
            document.getElementById('exam-title').textContent = data.data.title;
            renderQuestion();
            break;
        }
        case 'card': {
            card.classList.remove('hidden');
            exam.classList.add('hidden');
            document.getElementById('c-first').textContent = data.data.firstname || '—';
            document.getElementById('c-last').textContent = data.data.lastname || '—';
            document.getElementById('c-birth').textContent = data.data.birthdate || '—';
            document.getElementById('c-gender').textContent = data.data.gender || '—';
            document.getElementById('c-fin').textContent = data.data.fin || '19600000000';
            document.getElementById('c-blood').textContent = data.data.blood || '—';
            document.getElementById('c-license').textContent = data.data.license || '—';
            document.getElementById('c-weapon').textContent = data.data.weapon || '—';
            break;
        }
        case 'hide': {
            exam.classList.add('hidden');
            card.classList.add('hidden');
            break;
        }
    }
});

function renderQuestion() {
    const q = questions[current];
    if (!q) return;
    document.getElementById('q-text').textContent = (current + 1) + '. ' + q.q;
    document.getElementById('q-index').textContent = (current + 1) + ' / ' + questions.length;

    const box = document.getElementById('q-answers');
    box.innerHTML = '';
    q.a.forEach(function (text, idx) {
        const el = document.createElement('div');
        el.className = 'answer' + (answers[current] === idx + 1 ? ' selected' : '');
        el.textContent = ['A', 'B', 'C', 'D'][idx] + ') ' + text;
        el.addEventListener('click', function () {
            answers[current] = idx + 1;
            document.querySelectorAll('.answer').forEach(function (a) { a.classList.remove('selected'); });
            el.classList.add('selected');
        });
        box.appendChild(el);
    });
}

document.getElementById('btn-next').addEventListener('click', function () {
    if (current < questions.length - 1) { current++; renderQuestion(); }
});
document.getElementById('btn-prev').addEventListener('click', function () {
    if (current > 0) { current--; renderQuestion(); }
});
document.getElementById('btn-submit').addEventListener('click', function () {
    fetch('https://196rp_municipal/examSubmit', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ answers: answers }),
    });
});
document.getElementById('btn-exit').addEventListener('click', function () {
    fetch('https://196rp_municipal/examClose', { method: 'POST' });
});
document.getElementById('card-close').addEventListener('click', function () {
    fetch('https://196rp_municipal/cardClose', { method: 'POST' });
});
document.addEventListener('keyup', function (e) {
    if (e.key === 'Escape') {
        if (!card.classList.contains('hidden')) {
            fetch('https://196rp_municipal/cardClose', { method: 'POST' });
        } else if (!exam.classList.contains('hidden')) {
            fetch('https://196rp_municipal/examClose', { method: 'POST' });
        }
    }
});
