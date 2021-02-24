Set WshShell = CreateObject("WScript.Shell")
Dim JumpToKey
JumpToKey="Computer\" + Inputbox("跳转到")
WshShell.RegWrite "HKCU\Software\Microsoft\Windows\CurrentVersion\Applets\Regedit\Lastkey",JumpToKey,"REG_SZ"
WshShell.Run "regedit", 1,True
Set WshShell = Nothing