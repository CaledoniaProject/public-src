// 均未测试
function lose_in_webkit(url) {
  // chrome loses it in data uris
  location = "data:text/html,<script>location='" + url + '&_=' + Math.random() + "'</scr" + "ipt>";
  return false;
}

function lose_in_ie(url) {
  // ie loses referer in window.open()
  window.open(url + '&_=' + Math.random());
}

function lose_in_ff(url) {
  // ff needs data:uri  AND meta refresh. Firefox, WebKit and Opera
  location = 'data:text/html,<html><meta http-equiv="refresh" content="0; url=' + url + '"></html>';
}

function post_and_lose(url) {
  // POST request, WebKit & Firefox. Data, meta & form submit trinity
  location = 'data:text/html,<html><meta http-equiv="refresh" content="0; url=data:text/html,<form id=f method=post action=\'' + url + '\'></form><script>document.getElementById(\'f\').submit()</scri' + 'pt>"></html>';
}