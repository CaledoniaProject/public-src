# 未测试，获取远程主机 windows defender 配置
# https://www.fortynorthsecurity.com/remotely-enumerate-anti-virus-configurations/

$pass = ConvertTo-SecureString "XXX" -AsPlainText –Force
$cred = New-Object System.Management.Automation.PSCredential("corp\\admin", $pass)
$opt  = New-CimSessionOption -Protocol DCOM

$sess = New-CIMSession -ComputerName 172.16.177.131 -Credential $creds -SessionOption $opt
Get-MpPreference -CimSession $sess
