$s = New-Object System.DirectoryServices.DirectorySearcher
$s.Filter = "(|(userAccountControl:1.2.840.113556.1.4.803:=524288)(msDS-AllowedToDelegateTo=*))"
$s.FindAll()
