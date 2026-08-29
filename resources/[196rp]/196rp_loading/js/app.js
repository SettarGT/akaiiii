// 196 RP - Yüklənmə ekranı
const tips = [
    'İpucu: İş axtarırsınızsa, Bələdiyyə binasına yaxınlaşın və oradakı elan lövhəsindən iş seçin!',
    'İpucu: Balıq tutmaq üçün sahilə gedin, balıqçılıq işi ən gəlirli işlərdən biridir!',
    'İpucu: Avtomobilinizə yanacaq doldurmağı unutmayın — yanacaqdoldurma məntəqələri xəritədə qeyd olunub!',
    'İpucu: Paltarınızı dəyişmək üçün şəhərin hər yerində paltar mağazaları var!',
    'İpucu: Bank kartınızdan istifadə edərək pul köçürmək üçün banka və ya bankomata yaxınlaşın!',
    'İpucu: Ev almaq istəyirsiniz? Daşınmaz əmlak agentliyinə baş çəkin!',
    'İpucu: Mexanik emalatxanası avtomobilinizi təmir edə bilər — işlərin siyahısına baxın!',
    'İpucu: Polis və ya təcili yardım işi üçün şəhər rəhbərliyinə müraciət edin!',
    'İpucu: Xəritəni açmaq üçün M düyməsini basın — bütün məkanlar orada qeyd olunub!',
    'İpucu: Yeni şəhərə xoş gəlmisiniz! 196 RP-də hər kəs üçün bir iş, bir ev və bir həyat var!',
];

const statuses = [
    'Serverə qoşulur...',
    'Şəhər yüklənir...',
    'Xəritə hazırlanır...',
    'İşlər və məkanlar açılır...',
    'Hər şey hazırlanır...',
];

const fill = document.getElementById('progressFill');
const percentEl = document.getElementById('progressPercent');
const statusEl = document.getElementById('progressStatus');
const tipEl = document.getElementById('tipText');

let progress = 0;
let tipIndex = Math.floor(Math.random() * tips.length);
tipEl.textContent = tips[tipIndex];

function setProgress(value, status) {
    progress = Math.min(100, Math.max(progress, value));
    fill.style.width = progress + '%';
    percentEl.textContent = Math.round(progress) + '%';
    if (status) statusEl.textContent = status;
}

// FiveM loading hadisələri
window.addEventListener('message', (event) => {
    const data = event.data || {};
    switch (data.eventName) {
        case 'onClientMapStart':
            setProgress(35, 'Xəritə yüklənir...');
            break;
        case 'onClientMapLoaded':
            setProgress(65, 'Şəhər hazırlanır...');
            break;
        case 'onClientGameTypeStart':
            setProgress(80, 'Oyun modu yüklənir...');
            break;
        case 'onClientGameTypeLoaded':
            setProgress(100, 'Xoş gəldiniz!');
            break;
    }
});

// Fallback - tədricən artım (server hadisə göndərməsə də işləyir)
let statusIdx = 0;
const interval = setInterval(() => {
    if (progress < 90) {
        setProgress(progress + (Math.random() * 2));
        if (Math.random() > 0.7) {
            statusEl.textContent = statuses[statusIdx % statuses.length];
            statusIdx++;
        }
    } else if (progress >= 100) {
        clearInterval(interval);
    }
}, 900);

// İpuclarını dəyiş
setInterval(() => {
    tipIndex = (tipIndex + 1) % tips.length;
    tipEl.style.opacity = 0;
    setTimeout(() => {
        tipEl.textContent = tips[tipIndex];
        tipEl.style.opacity = 1;
    }, 300);
}, 12000);
