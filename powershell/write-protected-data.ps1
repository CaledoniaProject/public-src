Add-Type -AssemblyName System.Security
$a = [System.IO.File]::ReadAllBytes("testdata")
$b = [System.Security.Cryptography.ProtectedData]::Protect($a, $null, [System.Security.Cryptography.DataProtectionScope]::LocalMachine)
New-ItemProperty -Path "HKCU:\Test" -Name "protected" -Value $b -Force
