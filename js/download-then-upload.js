// 从指定地址下载，然后再 POST 到其他地址

var req = new XMLHttpRequest()
req.open('GET', '/index.html')
req.responseType = 'blob'
req.onload = function () {
	var blob = new Blob([req.response], { type: 'application/x-zip-compressed' })
	var name = '1.zip'
	var file = new File([blob], name)

	var req2 = new XMLHttpRequest()
	req2.open('POST', '/demo/dump.php')

	var formData = new FormData();
	formData.append("myfile", file);
	req2.send(formData);
}
req.send()
