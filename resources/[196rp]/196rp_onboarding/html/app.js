window.addEventListener('message', function (event) {
    const data = event.data;
    if (!data || !data.action) return;

    switch (data.action) {
        case 'welcome': {
            const box = document.getElementById('welcome');
            box.querySelector('.w-title').textContent = data.data.title || '196 RP';
            box.querySelector('.w-sub').textContent = '— ' + (data.data.subtitle || 'Yeni Era') + ' —';
            box.querySelector('.w-title2').textContent = data.data.title2 || '196 RP-yə Xoş Gəlmisiniz';
            box.classList.remove('hidden');
            break;
        }
        case 'welcome_hide': {
            const box = document.getElementById('welcome');
            box.classList.add('hidden');
            break;
        }
        case 'tip': {
            const tip = document.getElementById('tip');
            tip.classList.remove('hidden');
            document.getElementById('tip-icon').textContent = data.data.icon || '💬';
            document.getElementById('tip-title').textContent = data.data.title || '';
            document.getElementById('tip-text').textContent = data.data.text || '';
            break;
        }
        case 'tip_hide': {
            document.getElementById('tip').classList.add('hidden');
            break;
        }
    }
});
