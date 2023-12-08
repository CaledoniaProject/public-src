# 禁用 Windows Defender，需要管理权限；通知中心会弹窗
# http://www.labofapenetrationtester.com/2016/09/
#
# 更多内容可通过 Get-MpPreference 查看 

Set-MpPreference -DisableRealtimeMonitoring $true
Set-MpPreference -DisableIOAVProtection $true

# 或者增加隔离目录
Add-MpPreference -ExclusionPath "c:\temp"
