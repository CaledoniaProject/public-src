-- SQLServer 2008 之后删除

exec sp_makewebtask
@outputfile = 'c:\windows\temp\1.txt', 
@query= 'select cast (0x41414141 as varchar (5000))'
