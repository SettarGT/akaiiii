const { ref } = Vue

// Customize language for dialog menus and carousels here

const load = Vue.createApp({
  setup () {
    return {
      CarouselText1: 'Xoş gəlmisiniz! Bu serverdə hər şey sizin üçün hazırdır.',
      CarouselSubText1: '196 RP | Azerbaijan Role Play',
      CarouselText2: 'RP qaydalarına əməl edin və digər oyunçulara hörmət göstərin.',
      CarouselSubText2: '196 RP | Azerbaijan Role Play',
      CarouselText3: 'Qeydiyyat və whitelist məlumatları üçün Discordumuza qoşulun.',
      CarouselSubText3: '196 RP | Azerbaijan Role Play',
      CarouselText4: '196 RP | Azerbaijan Role Play — Ən yaxşı Azərbaycan RP serveri!',
      CarouselSubText4: '196 RP | Azerbaijan Role Play',

      DownloadTitle: '196 RP | Azerbaijan Role Play',
      DownloadDesc: "196 RP serverinə qoşulursunuz. Zəhmət olmasa gözləyin... \n\nServer yükləndikdən sonra avtomatik oyuna daxil olacaqsınız.",

      SettingsTitle: 'Parametrlər',
      AudioTrackDesc1: 'Söndürüldükdə cari musiqi dayandırılacaq.',
      AutoPlayDesc2: 'Söndürüldükdə şəkillər fırlanmağı dayandıracaq.',
      PlayVideoDesc3: 'Söndürüldükdə video dayandırılacaq.',

      KeybindTitle: 'Standart Düymələr',
      Keybind1: 'İnventarı Aç',
      Keybind2: 'Yaxınlıq Rejimi',
      Keybind3: 'Telefonu Aç',
      Keybind4: 'Təhlükəsizlik Kəməri',
      Keybind5: 'Hədəf Menyusu',
      Keybind6: 'Radial Menyu',
      Keybind7: 'HUD Menyusu',
      Keybind8: 'Radio ilə Danış',
      Keybind9: 'Skorbord Aç',
      Keybind10: 'Maşın Qapıları',
      Keybind11: 'Mühərrik',
      Keybind12: 'Göstərici Emote',
      Keybind13: 'Düymə Yerləri',
      Keybind14: 'Əllər Yuxarı',
      Keybind15: 'Əşya Yerləri',
      Keybind16: 'Kruiz Kontrol',

      firstap: ref(true),
      secondap: ref(true),
      thirdap: ref(true),
      firstslide: ref(1),
      secondslide: ref('1'),
      thirdslide: ref('5'),
      audioplay: ref(true),
      playvideo: ref(true),
      download: ref(true),
      settings: ref(false),
    }
  }
})

load.use(Quasar, { config: {} })
load.mount('#loading-main')

var audio = document.getElementById("audio");
audio.volume = 0.05;

function audiotoggle() {
    var audio = document.getElementById("audio");
    if (audio.paused) {
        audio.play();
    } else {
        audio.pause();
    }
}

function videotoggle() {
    var video = document.getElementById("video");
    if (video.paused) {
        video.play();
    } else {
        video.pause();
    }
}

let count = 0;
let thisCount = 0;

const handlers = {
    startInitFunctionOrder(data) {
        count = data.count;
    },

    initFunctionInvoking(data) {
        document.querySelector(".thingy").style.left = "0%";
        document.querySelector(".thingy").style.width = (data.idx / count) * 100 + "%";
    },

    startDataFileEntries(data) {
        count = data.count;
    },

    performMapLoadFunction(data) {
        ++thisCount;

        document.querySelector(".thingy").style.left = "0%";
        document.querySelector(".thingy").style.width = (thisCount / count) * 100 + "%";
    },
};

window.addEventListener("message", function (e) {
    (handlers[e.data.eventName] || function () {})(e.data);
});
