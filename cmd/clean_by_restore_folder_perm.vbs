' 自动修复根目录下面所有文件夹权限，病毒会隐藏他们

On Error Resume Next

Function FilesTree(sPath)     
    Set ws = CreateObject("WScript.Shell")
    Set oFso = CreateObject("Scripting.FileSystemObject")   
    Set oFolder = oFso.GetFolder(sPath)   
    Set oSubFolders = oFolder.SubFolders   
    
    'Set oFiles = oFolder.Files   
    'For Each oFile In oFiles   
    '   WScript.Echo oFile.Path   
    'Next
  
    For Each oSubFolder In oSubFolders   
       'WScript.Echo oSubFolder.Path
       ws.run "attrib " & " -s -a -r -h " & oSubFolder.Path,0,0
       'FilesTree(oSubFolder.Path)  
    Next
     
    Set oFolder = Nothing   
    Set oSubFolders = Nothing  
    Set oFso = Nothing  
End Function

FilesTree("D:")
FilesTree("E:")
FilesTree("F:")
