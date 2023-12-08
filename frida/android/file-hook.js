// 下载地址
// https://github.com/OWASP/owasp-mstg/raw/master/Crackmes/Android/Level_01/UnCrackable-Level1.apk

Java.perform(function () {
	var main = Java.use('sg.vantagepoint.uncrackable1.MainActivity')
	var file = Java.use('java.io.File')
	var c = Java.use('sg.vantagepoint.a.c')
	main.a.implementation = function(arg1) {
		console.log(c.a(), c.b(), c.c())
	}
	file.exists.implementation = function() {
		console.log(this.getName())
		return false
	}
})
