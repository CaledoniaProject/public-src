-- 删除不用的扩展

use master 
exec sp_dropextendedproc 'xp_cmdshell' 
exec sp_dropextendedproc 'xp_dirtree'
exec sp_dropextendedproc 'xp_enumgroups'
exec sp_dropextendedproc 'xp_fixeddrives'
exec sp_dropextendedproc 'xp_loginconfig'
exec sp_dropextendedproc 'xp_enumerrorlogs'
exec sp_dropextendedproc 'xp_getfiledetails'
exec sp_dropextendedproc 'Sp_OACreate' 
exec sp_dropextendedproc 'Sp_OADestroy' 
exec sp_dropextendedproc 'Sp_OAGetErrorInfo' 
exec sp_dropextendedproc 'Sp_OAGetProperty' 
exec sp_dropextendedproc 'Sp_OAMethod' 
exec sp_dropextendedproc 'Sp_OASetProperty' 
exec sp_dropextendedproc 'Sp_OAStop' 
exec sp_dropextendedproc 'Xp_regaddmultistring' 
exec sp_dropextendedproc 'Xp_regdeletekey' 
exec sp_dropextendedproc 'Xp_regdeletevalue' 
exec sp_dropextendedproc 'Xp_regenumvalues' 
exec sp_dropextendedproc 'Xp_regread' 
exec sp_dropextendedproc 'Xp_regremovemultistring' 
exec sp_dropextendedproc 'Xp_regwrite' 
drop procedure sp_makewebtask
go

