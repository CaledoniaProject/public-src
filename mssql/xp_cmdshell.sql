drop procedure xp_cmdshell;
exec sp_addextendedproc 'xp_cmdshell', 'xplog70.dll'
dbcc sp_addextendedproc ('xp_cmdshell', 'xplog70.dll')
