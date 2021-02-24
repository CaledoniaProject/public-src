REM 关闭AV、防火墙，以及对应的监控和通知

reg add "HKLM\SOFTWARE\Microsoft\Security Center" /v UpdatesOverride /t REG_DWORD /f /d 1
reg add "HKLM\SOFTWARE\Microsoft\Security Center" /v AntiVirusOverride /t REG_DWORD /f /d 1
reg add "HKLM\SOFTWARE\Microsoft\Security Center" /v AntiSpywareOverride /t REG_DWORD /f /d 1
reg add "HKLM\SOFTWARE\Microsoft\Security Center" /v FirewallOverride /t REG_DWORD /f /d 1
reg add "HKLM\SOFTWARE\Microsoft\Security Center" /v AntiVirusDisableNotify /t REG_DWORD /f /d 1
reg add "HKLM\SOFTWARE\Microsoft\Security Center" /v AutoUpdateDisableNotify /t REG_DWORD /f /d 1
reg add "HKLM\SOFTWARE\Microsoft\Security Center" /v FirewallDisableNotify /t REG_DWORD /f /d 1

