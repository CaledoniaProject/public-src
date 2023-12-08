USE msdb;
EXEC sp_delete_job null, 'vb'
EXEC sp_add_job 'vb';
EXEC sp_add_jobstep null, 'vb', null, '1', 'cmdexec', 'cmd /c xxx';
EXEC sp_add_jobserver null, 'vb';
EXEC sp_start_job 'vb';