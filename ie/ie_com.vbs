dim ie_com, headers, resp
Set ie_com     = CreateObject("InternetExplorer.Application")
ie_com.Silent  = true
ie_com.Visible = false
headers = "Host: www.bing.com" & vbCrLf
ie_com.Navigate2 "https://www.bing.com", 14, 0, null, headers
While(ie_com.busy)
    WScript.Sleep 1
    'CreateObject("WScript.Shell").Run "ping 127.0.0.1 -n 1", 0, True <<< if WScript object is unavailable
Wend
resp = ie_com.document.body.innerHTML
msgbox resp
ie_com.Quit
