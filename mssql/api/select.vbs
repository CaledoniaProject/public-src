Set conn = CreateObject("ADODB.Connection")
Set rs   = CreateObject("ADODB.Recordset")

conn.Open "Driver={SQL Server};Server=127.0.0.1;Uid=XXX;Pwd=XXX;"

Set rs = conn.Execute("EXEC xp_cmdshell 'whoami';")

' Loops through every row
Do Until rs.EOF

    ' Loops through every field
    For i = 0 to rs.Fields.Count - 1
        WScript.Echo rs.Fields(i).Name & " = " & CStr(rs.Fields(i))
    Next
    WScript.Echo "--BREAK--"

    rs.MoveNext
Loop

rs.Close
conn.Close
