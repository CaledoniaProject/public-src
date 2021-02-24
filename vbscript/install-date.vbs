strComputer = "."

Set objWMIService = GetObject("winmgmts:\\" & _
    strComputer & "\root\cimv2")

Set colOperatingSystems = _
    objWMIService.ExecQuery _
    ("Select * from Win32_OperatingSystem")

For Each objOperatingSystem in _
    colOperatingSystems
    Wscript.Echo objOperatingSystem.InstallDate 
Next
