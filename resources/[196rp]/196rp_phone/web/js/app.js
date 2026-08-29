/* 196 RP Telefon — premium NUI məntiqi
   FiveM-də NUI callback-ə, brauzerdə (dizayn baxışı) konsol stub-a yazır. */

(function () {
  'use strict';

  var state = {
    number: '',
    name: 'Qonaq',
    contacts: [],
    messages: [],
    money: 0,
    dial: '',
    currentView: 'home',
    inCall: false,
    incoming: false
  };

  var el = {};
  ['phone','sbTime','meName','dialNum','btnCall','btnDel','msgList','btnNewMsg',
   'compose','cmpTo','cmpText','cmpSend','cmpCancel','contactList','btnNewContact',
   'contactForm','cfName','cfNumber','cfSave','cfCancel','bcNum','bcName','bcBal',
   'v-home','v-dial','v-msg','v-contact','v-bank','v-call','callName','callState',
   'callAvatar','btnHangup','btnAnswer','btnClosePhone'
  ].forEach(function (id) { el[id] = document.getElementById(id); });

  var isNui = typeof window.GetParentResourceName === 'function';

  function post(data) {
    if (isNui) {
      fetch('https://' + window.GetParentResourceName() + '/' + data.action, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data)
      }).catch(function () {});
    } else if (window.console) {
      console.log('[phone-demo]', data.action, data);
    }
  }

  // ---------- saat ----------
  function tick() {
    var d = new Date();
    var h = ('0' + d.getHours()).slice(-2);
    var m = ('0' + d.getMinutes()).slice(-2);
    el.sbTime.textContent = h + ':' + m;
  }
  setInterval(tick, 1000); tick();

  // ---------- görünüş keçidləri ----------
  function show(name) {
    state.currentView = name;
    ['home','dial','msg','contact','bank','call'].forEach(function (v) {
      el['v-' + v].classList.toggle('active', v === name);
    });
  }

  document.querySelectorAll('.app').forEach(function (btn) {
    btn.addEventListener('click', function () { show(btn.getAttribute('data-app')); });
  });

  document.querySelectorAll('[data-back]').forEach(function (btn) {
    btn.addEventListener('click', function () { show('home'); });
  });

  el.btnClosePhone.addEventListener('click', function () {
    el.phone.classList.add('hidden');
    post({ action: 'close' });
  });

  // ---------- dialer ----------
  document.querySelectorAll('[data-d]').forEach(function (btn) {
    btn.addEventListener('click', function () {
      if (state.dial.length < 12) state.dial += btn.getAttribute('data-d');
      renderDial();
    });
  });

  el.btnDel.addEventListener('click', function () {
    state.dial = state.dial.slice(0, -1);
    renderDial();
  });

  function renderDial() {
    el.dialNum.textContent = state.dial || '\u00a0';
  }

  el.btnCall.addEventListener('click', function () {
    if (!state.dial) return;
    openCall(nameForNumber(state.dial), state.dial, 'Zəng edilir...', false);
    post({ action: 'dial', number: state.dial });
  });

  // ---------- kontaktlar ----------
  function nameForNumber(num) {
    for (var i = 0; i < state.contacts.length; i++) {
      if (state.contacts[i].number === num) return state.contacts[i].name;
    }
    return num;
  }

  function renderContacts() {
    el.contactList.innerHTML = '';

    state.contacts.forEach(function (c) {
      var li = document.createElement('li');
      li.className = 'contact';

      var av = document.createElement('div');
      av.className = 'avatar';
      av.textContent = (c.name || '?').charAt(0).toUpperCase();

      var main = document.createElement('div');
      main.className = 't-main';
      var nm = document.createElement('div');
      nm.className = 't-name'; nm.textContent = c.name;
      var sub = document.createElement('div');
      sub.className = 't-sub'; sub.textContent = c.number;
      main.appendChild(nm); main.appendChild(sub);

      var acts = document.createElement('div');
      acts.className = 'c-actions';

      var callB = document.createElement('button');
      callB.innerHTML = '<svg viewBox="0 0 24 24"><path d="M6.6 10.8c1.4 2.8 3.8 5.1 6.6 6.6l2.2-2.2c.3-.3.7-.4 1-.2 1.1.4 2.4.6 3.6.6.6 0 1 .4 1 1V20c0 .6-.4 1-1 1C10.6 21 3 13.4 3 4c0-.6.4-1 1-1h3.5c.6 0 1 .4 1 1 0 1.3.2 2.5.6 3.6.1.3 0 .7-.2 1l-2.3 2.2z"/></svg>';
      callB.addEventListener('click', function () {
        openCall(c.name, c.number, 'Zəng edilir...', false);
        post({ action: 'dial', number: c.number });
      });

      var msgB = document.createElement('button');
      msgB.innerHTML = '<svg viewBox="0 0 24 24"><path d="M12 3C6.5 3 2 6.9 2 11.7c0 2.6 1.3 4.9 3.4 6.5-.2.8-.7 2-1.6 3 .1.1 2.4-.1 4.3-1.2 1.2.4 2.5.6 3.9.6 5.5 0 10-3.9 10-8.7S17.5 3 12 3z"/></svg>';
      msgB.addEventListener('click', function () {
        el.cmpTo.value = c.number;
        show('msg');
        el.compose.style.display = 'flex';
      });

      var delB = document.createElement('button');
      delB.className = 'del-c';
      delB.innerHTML = '<svg viewBox="0 0 24 24"><path d="M6 6l12 12M18 6L6 18" stroke="currentColor" stroke-width="2" fill="none"/></svg>';
      delB.addEventListener('click', function () {
        post({ action: 'removeContact', id: c.id });
        state.contacts = state.contacts.filter(function (x) { return x.id !== c.id; });
        renderContacts();
      });

      acts.appendChild(callB); acts.appendChild(msgB); acts.appendChild(delB);

      li.appendChild(av); li.appendChild(main); li.appendChild(acts);
      el.contactList.appendChild(li);
    });
  }

  el.btnNewContact.addEventListener('click', function () {
    el.contactForm.style.display = 'flex';
  });
  el.cfCancel.addEventListener('click', function () {
    el.contactForm.style.display = 'none';
  });
  el.cfSave.addEventListener('click', function () {
    var name = el.cfName.value.trim();
    var number = el.cfNumber.value.trim();
    if (!name || !number) return;
    post({ action: 'addContact', name: name, number: number });
    state.contacts.push({ id: Date.now(), name: name, number: number });
    renderContacts();
    el.cfName.value = ''; el.cfNumber.value = '';
    el.contactForm.style.display = 'none';
  });

  // ---------- mesajlar ----------
  function renderMessages() {
    el.msgList.innerHTML = '';

    state.messages.forEach(function (m) {
      var li = document.createElement('li');
      li.className = 'thread';

      var av = document.createElement('div');
      av.className = 'avatar';
      av.textContent = (m.from || '?').charAt(0).toUpperCase();

      var main = document.createElement('div');
      main.className = 't-main';
      var nm = document.createElement('div');
      nm.className = 't-name'; nm.textContent = m.from + ' · ' + (m.fromNumber || '');
      var sub = document.createElement('div');
      sub.className = 't-sub'; sub.textContent = m.message;
      main.appendChild(nm); main.appendChild(sub);

      li.appendChild(av); li.appendChild(main);
      li.addEventListener('click', function () {
        el.cmpTo.value = m.fromNumber || '';
        el.compose.style.display = 'flex';
      });
      el.msgList.appendChild(li);
    });
  }

  el.btnNewMsg.addEventListener('click', function () {
    el.compose.style.display = 'flex';
  });
  el.cmpCancel.addEventListener('click', function () {
    el.compose.style.display = 'none';
  });
  el.cmpSend.addEventListener('click', function () {
    var to = el.cmpTo.value.trim();
    var text = el.cmpText.value.trim();
    if (!to || !text) return;
    post({ action: 'sendSMS', number: to, message: text });
    state.messages.unshift({ from: nameForNumber(to), fromNumber: to, message: text });
    renderMessages();
    el.cmpText.value = '';
    el.compose.style.display = 'none';
  });

  // ---------- bank ----------
  function renderBank() {
    el.bcName.textContent = state.name;
    el.bcBal.textContent = fmtMoney(state.money);
    el.bcNum.textContent = maskNumber(state.number);
  }

  function fmtMoney(n) {
    n = Math.round(n || 0);
    return String(n).replace(/\B(?=(\d{3})+(?!\d))/g, ' ') + ' ₼';
  }

  function maskNumber(num) {
    if (!num) return '•••• ••••';
    return String(num).replace(/.(?=.{0,2}$)/g, '•').slice(0, 12);
  }

  // ---------- zəng ----------
  function openCall(name, number, stateText, incoming) {
    state.inCall = true;
    state.incoming = incoming;
    el.callName.textContent = name || number;
    el.callState.textContent = stateText;
    el.callAvatar.textContent = (name || number || '?').charAt(0).toUpperCase();
    el.btnAnswer.style.display = incoming ? 'grid' : 'none';
    show('call');
  }

  el.btnHangup.addEventListener('click', function () {
    state.inCall = false;
    show('home');
    post({ action: state.incoming ? 'reject' : 'hangup' });
  });

  el.btnAnswer.addEventListener('click', function () {
    state.incoming = false;
    el.callState.textContent = 'Danışıqdadır...';
    el.btnAnswer.style.display = 'none';
    post({ action: 'answer' });
  });

  document.addEventListener('keydown', function (e) {
    if (e.key === 'Escape' && !el.phone.classList.contains('hidden')) {
      el.phone.classList.add('hidden');
      post({ action: 'close' });
    }
  });

  // ---------- məlumat ----------
  function setData(d) {
    state.number = d.number || '';
    state.name = d.name || 'Qonaq';
    state.contacts = d.contacts || [];
    state.messages = d.messages || [];
    state.money = d.money || 0;
    state.dial = '';

    el.meName.textContent = state.name;
    renderDial(); renderContacts(); renderMessages(); renderBank();
  }

  function open(d) {
    if (d) setData(d);
    el.phone.classList.remove('hidden');
    show('home');
  }

  window.addEventListener('message', function (e) {
    var d = e.data || {};

    if (d.action === 'open') open(d);
    else if (d.action === 'close') el.phone.classList.add('hidden');
    else if (d.action === 'incomingCall') openCall(d.name, d.number, 'Gələn zəng...', true);
    else if (d.action === 'callStarted') { el.callState.textContent = 'Danışıqdadır...'; state.incoming = false; el.btnAnswer.style.display = 'none'; }
    else if (d.action === 'callEnded') { state.inCall = false; show('home'); }
    else if (d.action === 'newMessage') {
      state.messages.unshift(d.message);
      renderMessages();
    }
    else if (d.action === 'bank') { state.money = d.money; renderBank(); }
  });

  // ---------- DEMO (brauzer baxışı üçün) ----------
  if (!isNui) {
    open({
      number: '555-0196',
      name: 'Rəşad Məmmədov',
      money: 12540,
      contacts: [
        { id: 1, name: 'Anar', number: '555-0101' },
        { id: 2, name: 'Leyla', number: '555-0102' },
        { id: 3, name: '196 Mobil', number: '555-0196' }
      ],
      messages: [
        { from: 'Anar', fromNumber: '555-0101', message: 'Sabah görüşək?' },
        { from: '196 Mobil', fromNumber: '555-0196', message: 'Xoş gəldiniz! Yeni Aifon 16 Pro mağazada.' }
      ]
    });
  }
})();
