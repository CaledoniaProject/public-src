use msdb;
declare @name varchar(25);
set @name = N'101';

exec sp_add_job @job_name = @name;
exec sp_add_jobstep @job_name = @name,
@step_name = N'step1', 
@subsystem = 'PowerShell', 
@command = N'powershell.exe XXX")',
@retry_attempts = 1,
@retry_interval = 5;

exec sp_add_jobserver @job_name = @name;
exec sp_start_job @name;
