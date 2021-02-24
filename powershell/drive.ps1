
# 创建一个只有当前powershell能看到的盘符
New-PSDrive -Name Y -PSProvider filesystem -Root "\\172.16.177.131\\c$"
Remove-PSDrive -Name Z

