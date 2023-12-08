strLink   = "http://example.com/xxx.exe"
strSaveTo = "c:\\xxx.exe"

Set objHTTP = CreateObject( "WinHttp.WinHttpRequest.5.1" )

objHTTP.Open "GET", strLink, False
objHTTP.Send

Set objFSO = CreateObject("Scripting.FileSystemObject")
If objFSO.FileExists(strSaveTo) Then
    objFSO.DeleteFile(strSaveTo)
End If

If objHTTP.Status = 200 Then
    Dim objStream
    Set objStream = CreateObject("ADODB.Stream")
    With objStream
        .Type = 1
        .Open
        .Write objHTTP.ResponseBody
        .SaveToFile strSaveTo
        .Close
    End With
    set objStream = Nothing
End If
