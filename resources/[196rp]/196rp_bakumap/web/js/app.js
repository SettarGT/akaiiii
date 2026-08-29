/* 196 RP | Bakı Xəritə — original UI məntiqi
   Heç bir xarici kitabxana istifadə olunmur. */

(function () {
  'use strict';

  var W = 1000, H = 700, PAD = 62;

  var state = {
    stations: [],
    lines: [],
    player: { x: 0, y: 0 },
    district: null,
    selected: null,
    hidden: {},          // lineId -> true (filtr)
    bounds: null
  };

  var el = {
    root: document.getElementById('root'),
    lines: document.getElementById('lines'),
    stationList: document.getElementById('stationList'),
    detail: document.getElementById('detail'),
    districtName: document.getElementById('districtName'),
    clock: document.getElementById('clock'),
    counter: document.getElementById('counter'),
    lineLayer: document.getElementById('lineLayer'),
    nodeLayer: document.getElementById('nodeLayer'),
    playerLayer: document.getElementById('playerLayer'),
    btnClose: document.getElementById('btnClose')
  };

  // FiveM blip rəng enumu → CSS rəng (original palitra)
  var LINE_COLOURS = {
    1: '#ff6b6b',   // qırmızı
    2: '#35e0c0',
    3: '#4ade80',   // yaşıl
    4: '#f472b6',
    5: '#e9c79a',
    6: '#e8eef6',
    7: '#a78bfa'    // bənövşəyi
  };

  function lineColour(line) {
    if (!line) return '#7aa2ff';
    return LINE_COLOURS[line.colour] || LINE_COLOURS[line.id] || '#7aa2ff';
  }

  function byId(id) {
    for (var i = 0; i < state.lines.length; i++) {
      if (state.lines[i].id === id) return state.lines[i];
    }
    return null;
  }

  // ---------- proyeksiya: dünya koordinatı → SVG ----------

  function computeBounds() {
    var xs = [], ys = [];
    state.stations.forEach(function (s) { xs.push(s.x); ys.push(s.y); });
    xs.push(state.player.x); ys.push(state.player.y);

    var minX = Math.min.apply(null, xs), maxX = Math.max.apply(null, xs);
    var minY = Math.min.apply(null, ys), maxY = Math.max.apply(null, ys);

    // kvadrat olmaması üçün minimum ölçü qoyuruq
    if (maxX - minX < 1) maxX = minX + 1;
    if (maxY - minY < 1) maxY = minY + 1;

    var scale = Math.min((W - PAD * 2) / (maxX - minX), (H - PAD * 2) / (maxY - minY));
    var cw = (maxX - minX) * scale, ch = (maxY - minY) * scale;

    state.bounds = {
      minX: minX, maxX: maxX, minY: minY, maxY: maxY,
      scale: scale,
      offX: (W - cw) / 2,
      offY: (H - ch) / 2
    };
  }

  function project(x, y) {
    var b = state.bounds;
    return {
      x: b.offX + (x - b.minX) * b.scale,
      y: b.offY + (b.maxY - y) * b.scale     // dünya Y+ şimaldır, SVG-də aşağı
    };
  }

  function dist(ax, ay, bx, by) {
    var dx = ax - bx, dy = ay - by;
    return Math.sqrt(dx * dx + dy * dy);
  }

  function fmt(n) {
    n = Math.round(n);
    if (n >= 1000) return (n / 1000).toFixed(1) + ' km';
    return n + ' m';
  }

  // ---------- xətlər paneli ----------

  function renderLines() {
    el.lines.innerHTML = '';

    state.lines.forEach(function (ln) {
      var count = state.stations.filter(function (s) { return s.line === ln.id; }).length;
      var row = document.createElement('div');
      row.className = 'line-row' + (state.hidden[ln.id] ? ' off' : '');

      var sw = document.createElement('span');
      sw.className = 'swatch';
      sw.style.background = lineColour(ln);

      var nm = document.createElement('span');
      nm.textContent = ln.name;

      var n = document.createElement('span');
      n.className = 'n';
      n.textContent = count + ' st.';

      row.appendChild(sw); row.appendChild(nm); row.appendChild(n);

      row.addEventListener('click', function () {
        state.hidden[ln.id] = !state.hidden[ln.id];
        renderAll();
      });

      el.lines.appendChild(row);
    });
  }

  // ---------- stansiya siyahısı ----------

  function renderList() {
    el.stationList.innerHTML = '';

    state.stations.forEach(function (s) {
      var ln = byId(s.line);
      var li = document.createElement('li');
      li.className = 'st' + (state.selected === s.id ? ' active' : '');

      var bar = document.createElement('span');
      bar.className = 'bar-c';
      bar.style.background = lineColour(ln);

      var wrap = document.createElement('div');
      var nm = document.createElement('div');
      nm.className = 'nm';
      nm.textContent = s.name;
      var ds = document.createElement('div');
      ds.className = 'ds';
      ds.textContent = ln ? ln.name : '';
      wrap.appendChild(nm); wrap.appendChild(ds);

      var mt = document.createElement('span');
      mt.className = 'mt';
      mt.textContent = fmt(dist(state.player.x, state.player.y, s.x, s.y));

      li.appendChild(bar); li.appendChild(wrap); li.appendChild(mt);

      li.addEventListener('click', function () {
        state.selected = s.id;
        renderAll();
      });

      el.stationList.appendChild(li);
    });
  }

  // ---------- SVG ----------

  function svg(tag, attrs) {
    var node = document.createElementNS('http://www.w3.org/2000/svg', tag);
    for (var k in attrs) {
      if (Object.prototype.hasOwnProperty.call(attrs, k)) node.setAttribute(k, attrs[k]);
    }
    return node;
  }

  function renderMap() {
    computeBounds();
    el.lineLayer.innerHTML = '';
    el.nodeLayer.innerHTML = '';
    el.playerLayer.innerHTML = '';

    // xətlər (stansiyaları order üzrə birləşdirir)
    state.lines.forEach(function (ln) {
      var pts = state.stations
        .filter(function (s) { return s.line === ln.id; })
        .sort(function (a, b) { return a.order - b.order; })
        .map(function (s) { return project(s.x, s.y); });

      if (pts.length < 2) return;

      var d = pts.map(function (p, i) { return (i ? 'L' : 'M') + p.x.toFixed(1) + ' ' + p.y.toFixed(1); }).join(' ');
      var path = svg('path', {
        d: d,
        class: 'route' + (state.hidden[ln.id] ? ' dim' : ''),
        stroke: lineColour(ln),
        filter: 'url(#glow)'
      });
      el.lineLayer.appendChild(path);
    });

    // stansiyalar
    state.stations.forEach(function (s) {
      var ln = byId(s.line);
      var p = project(s.x, s.y);
      var hidden = !!state.hidden[s.line];

      var g = svg('g', { class: 'node' + (state.selected === s.id ? ' sel' : '') + (hidden ? ' dim' : '') });

      if (state.selected === s.id) {
        g.appendChild(svg('circle', { class: 'halo', cx: p.x, cy: p.y, r: 11, fill: 'none', stroke: lineColour(ln), 'stroke-width': 2 }));
      }

      var core = svg('circle', {
        class: 'core', cx: p.x, cy: p.y, r: 6.5,
        fill: '#0b111b', stroke: lineColour(ln)
      });
      core.addEventListener('click', function () {
        state.selected = s.id;
        renderAll();
      });
      g.appendChild(core);

      var label = svg('text', { x: p.x + 11, y: p.y + 4 });
      label.textContent = s.name;
      g.appendChild(label);

      el.nodeLayer.appendChild(g);
    });

    // oyunçu
    var pp = project(state.player.x, state.player.y);
    el.playerLayer.appendChild(svg('circle', { class: 'pring', cx: pp.x, cy: pp.y, r: 7 }));
    el.playerLayer.appendChild(svg('circle', { class: 'pdot', cx: pp.x, cy: pp.y, r: 5 }));

    var pl = svg('text', { class: 'plabel', x: pp.x + 10, y: pp.y - 9 });
    pl.textContent = 'SİZ';
    el.playerLayer.appendChild(pl);
  }

  // ---------- detal paneli ----------

  function renderDetail() {
    var s = null;
    for (var i = 0; i < state.stations.length; i++) {
      if (state.stations[i].id === state.selected) s = state.stations[i];
    }

    if (!s) {
      el.detail.innerHTML =
        '<div class="empty"><div class="empty-icon">◎</div>' +
        '<p>Soldan bir stansiya seçin</p>' +
        '<small>Məsafə və xətt məlumatı burada görünəcək</small></div>';
      return;
    }

    var ln = byId(s.line);
    var d = dist(state.player.x, state.player.y, s.x, s.y);

    var same = state.stations
      .filter(function (o) { return o.line === s.line; })
      .sort(function (a, b) { return a.order - b.order; });

    var next = same.map(function (o) {
      return '<span class="' + (o.id === s.id ? 'here' : '') + '">' + o.name + '</span>';
    }).join('');

    el.detail.innerHTML =
      '<div class="d-head">' +
        '<div class="d-chip" style="background:' + lineColour(ln) + '"></div>' +
        '<div><div class="d-name">' + s.name + '</div>' +
        '<div class="d-line">' + (ln ? ln.name : '') + ' · stansiya ' + s.order + '/' + same.length + '</div></div>' +
      '</div>' +

      '<div class="d-card"><h4>Məsafə</h4>' +
        '<div class="d-metric"><b>' + fmt(d) + '</b></div>' +
        (state.district === s.id
          ? '<div class="d-nearest">◉ Hazırda bu rayondasınız</div>'
          : '') +
      '</div>' +

      '<div class="d-card"><h4>Rayon haqqında</h4><p>' + (s.desc || '—') + '</p></div>' +

      '<div class="d-card"><h4>Xətt üzrə</h4><div class="d-next">' + next + '</div></div>';
  }

  // ---------- ümumi ----------

  function renderAll() {
    renderLines();
    renderList();
    renderMap();
    renderDetail();
    el.counter.textContent = state.stations.length + ' stansiya · ' + state.lines.length + ' xətt';
  }

  function open(data) {
    state.stations = data.stations || [];
    state.lines = data.lines || [];
    state.player = data.player || { x: 0, y: 0 };
    state.district = data.district || null;
    state.hidden = {};
    state.selected = data.selected || null;

    var dn = null;
    state.stations.forEach(function (s) { if (s.id === state.district) dn = s.name; });
    el.districtName.textContent = dn || 'Şəhər kənarı';

    if (data.clock) el.clock.textContent = data.clock;

    el.root.classList.remove('hidden');
    renderAll();
  }

  function update(data) {
    if (data.player) state.player = data.player;
    if (data.clock) el.clock.textContent = data.clock;
    if (data.district !== undefined) {
      state.district = data.district;
      var dn = null;
      state.stations.forEach(function (s) { if (s.id === state.district) dn = s.name; });
      el.districtName.textContent = dn || 'Şəhər kənarı';
    }
    if (el.root.classList.contains('hidden')) return;
    renderList();
    renderMap();
    renderDetail();
  }

  function close() {
    el.root.classList.add('hidden');
    fetch('https://' + (window.GetParentResourceName ? window.GetParentResourceName() : '196rp_bakumap') + '/close', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({})
    }).catch(function () {});
  }

  window.addEventListener('message', function (e) {
    var d = e.data || {};
    if (d.action === 'open') open(d);
    else if (d.action === 'update') update(d);
    else if (d.action === 'close') el.root.classList.add('hidden');
  });

  el.btnClose.addEventListener('click', close);

  document.addEventListener('keydown', function (e) {
    if (e.key === 'Escape' && !el.root.classList.contains('hidden')) close();
  });
})();
