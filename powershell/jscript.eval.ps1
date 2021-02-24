[Reflection.Assembly]::LoadWithPartialName('Microsoft.JSCript')
$script = 'new ActiveXObject("WScript.Shell").Run("calc")'
[Microsoft.JSCript.Eval]::JScriptEvaluate($script, [Microsoft.JScript.Vsa.VsaEngine]::CreateEngine())

