// 来自
// https://gist.github.com/mcxiaoke/766a5e01939b6ddb7bec7674ad967a4a
// 
// 说明
// 解码 sinaimg 图片地址，获取微博 UID
//
// 测试
// node sina-img.js https://wx4.sinaimg.cn/mw690/53b74dd4gy1fot0nwo43dj20np0hst9j.jpg


function string62to10(number_code) {
    number_code = String(number_code);
    var chars = '0123456789abcdefghigklmnopqrstuvwxyzABCDEFGHIGKLMNOPQRSTUVWXYZ',
        radix = chars.length,
        len = number_code.length,
        i = 0,
        origin_number = 0;
    while (i < len) {
        origin_number += Math.pow(radix, i++) * chars.indexOf(number_code.charAt(len - i) || 0);
    }
    return origin_number;
}
function decode(url) {
    var lastIndexOfSlash = url.lastIndexOf('/');
    var number = url.substr(lastIndexOfSlash + 1, 8);
    if (number.startsWith('00')) {
        return string62to10(number);
    } else {
        return parseInt(number, 16);
    }
}


process.argv.slice(2).forEach (function (url) {
    var uid = decode(url)
    console.log (url)
    console.log ('https://weibo.com/u/' + uid)
    console.log ('')
})