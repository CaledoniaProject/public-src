// 让所有 video/audio 静音

var vi = document.getElementsByTagName("video");
var ai = document.getElementsByTagName("audio");
for (let i = 0; i < vi.length; i++) {
  vi[i].volume = 0
}
for (let i = 0; i < ai.length; i++) {
  al[i].muted = true
}

