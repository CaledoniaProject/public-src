$UserName = "aaa" 
$serverpass = "aaa"

$Password = ConvertTo-SecureString $serverpass -AsPlainText –Force 
$cred = New-Object System.Management.Automation.PSCredential($UserName,$Password)  
invoke-command -ComputerName 127.0.0.1 -Credential $cred -ScriptBlock { 

ipconfig
whoami

}
