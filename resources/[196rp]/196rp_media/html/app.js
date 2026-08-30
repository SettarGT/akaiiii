(() => {
    const tv = document.getElementById('tv');
    const urlInput = document.getElementById('tv-url');
    const frame = document.getElementById('tv-frame');

    function open(url) {
        tv.classList.remove('hidden');
        if (url) {
            urlInput.value = url;
            setSrc(url);
        }
    }
    function close() {
        tv.classList.add('hidden');
        frame.src = 'about:blank';
        fetch('https://196rp_media/close', { method: 'POST' });
    }

    function setSrc(url) {
        const yt = url.match(/(?:youtube\.com\/(?:watch\?v=|shorts\/|embed\/)|youtu\.be\/)([A-Za-z0-9_-]{6,})/);
        const tw = url.match(/twitch\.tv\/([A-Za-z0-9_]+)/);
        if (yt) {
            frame.src = 'https://www.youtube-nocookie.com/embed/' + yt[1] + '?autoplay=1';
        } else if (tw) {
            frame.src = 'https://player.twitch.tv/?channel=' + tw[1] + '&parent=localhost&muted=false';
        } else {
            frame.src = url;
        }
    }

    window.addEventListener('message', (e) => {
        if (!e.data) return;
        if (e.data.action === 'open') open(e.data.url || null);
        else if (e.data.action === 'close') close();
    });

    urlInput.addEventListener('keydown', (e) => {
        if (e.key === 'Enter') setSrc(urlInput.value.trim());
    });
    document.getElementById('tv-close').addEventListener('click', close);
    document.addEventListener('keydown', (e) => { if (e.key === 'Escape') close(); });
})();
