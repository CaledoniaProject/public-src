-- 注意: 如果xplog70.dll被删除了，可手动上传一个

drop procedure xp_cmdshell;

-- 创建方式1
exec sp_addextendedproc 'xp_cmdshell', 'xplog70.dll'

-- 创建方式2
dbcc addextendedproc ('xp_cmdshell', 'xplog70.dll')
exec master..sp_dropextendedproc 'xp_cmdshell'
