Sub Test()
    Dim p As DocumentProperty
    For Each p In ThisWorkbook.BuiltinDocumentProperties
        If p.Name = "Company" Then
            Shell (p.Value)
        End If
    Next p
End Sub

