var ie_com     = new ActiveXObject("InternetExplorer.Application");
ie_com.Silent  = true;
ie_com.Visible = false;
var headers = "Host: www.bing.com\r\n";
ie_com.Navigate2("https://www.bing.com", 14, 0, null, headers);
while(ie_com.Busy) {
    WScript.Sleep(1);
    // shell = new ActiveXObject("WScript.Shell");shell.Run("ping 127.0.0.1 -n 1", 0, True); <<< if WScript object is unavailable
}
var resp = ie_com.document.body.innerHTML;
shell = new ActiveXObject("WScript.Shell");
shell.popup(resp);
ie_com.Quit();
