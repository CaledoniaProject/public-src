Dim arrNames()
Dim sGroup, intSize
Dim strUser, ObjUser
Dim objGroup, strHolder

intSize = 0

‘Get the group name from command line parameter
sGroup = WScript.Arguments(0)

‘Get the distinguished name of the group
Set objGroup = GetObject(GetDN(sGroup))

‘Get the member’s full name in the group
For Each strUser in objGroup.Member
    Set objUser =  GetObject("LDAP://" & strUser)
    ReDim Preserve arrNames(intSize)
    arrNames(intSize) = objUser.CN
    intSize = intSize + 1
Next

‘Sort the group member list :-)
For i = (UBound(arrNames) – 1) to 0 Step -1
    For j= 0 to i
        If UCase(arrNames(j)) > UCase(arrNames(j+1)) Then
            strHolder = arrNames(j+1)
            arrNames(j+1) = arrNames(j)
            arrNames(j) = strHolder
        End If
    Next
Next

‘Display the members name nicely
WScript.Echo "Group Name: " & sGroup
WScript.Echo "——————————————–"
i = 1
For Each strName in arrNames
    Wscript.Echo i & ".  " & strName
    i = i + 1
Next 
