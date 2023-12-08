' 工具(T) -> 引用(R)，添加 Windows Script Host Object Model 
' 之后可直接使用 WshShell 等变量

Sub aaa()

    Dim a As WshShell
    Set a = New WshShell
    a.Run ("calc.exe")

End Sub

