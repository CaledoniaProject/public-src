Set WshShell = WScript.CreateObject("WScript.Shell")

WshShell.run "notepad"
WScript.Sleep 500

WshShell.sendKeys "Hello {Enter}"