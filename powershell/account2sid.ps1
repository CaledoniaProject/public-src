$objUser = New-Object System.Security.Principal.NTAccount("administrator")
$strSID = $objUser.Translate([System.Security.Principal.SecurityIdentifier])
$strSID.Value
