// 更多技巧
// https://stackoverflow.com/questions/9847580/how-to-detect-safari-chrome-ie-firefox-and-opera-browser
// 
// 用各种特殊技巧判断真实浏览器，如果和UA对不上，就认为是机器人
function is_bot() {
  var isMobile = 0
  var isIE = isChrome = isFirefox = isOpera = 0;
  if (/iphone|ipad|ipod|android|blackberry|mini|windows\sce|palm/i.test(navigator.userAgent)) {
    isMobile = 1
  }
  if ('ActiveXObject' in window) isIE++;
  if ('chrome' in window) isChrome++;
  if ('opera' in window) isOpera++;
  if ('getBoxObjectFor' in d || 'mozInnerScreenX' in w) isFirefox++;
  if ('WebKitCSSMatrix' in w || 'WebKitPoint' in w || 'webkitStorageInfo' in w || 'webkitURL' in w) isChrome++;
  
  var f = 0;
  f |= 'sandbox' in d.createElement('iframe') ? 1 : 0;
  f |= 'WebSocket' in w ? 2 : 0;
  f |= w.Worker ? 4 : 0;
  f |= w.applicationCache ? 8 : 0;
  f |= w.history && history.pushState ? 16 : 0;
  f |= d.documentElement.webkitRequestFullScreen ? 32 : 0;
  f |= 'FileReader' in w ? 64 : 0;
  if (f == 0) isIE++;

  
}
