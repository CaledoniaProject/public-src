Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Policies\System -Name a -Value $a

# 禁用 RestrictedAdmin
New-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Lsa" -Name "DisableRestrictedAdmin" -Value "0" -PropertyType DWORD -Force

