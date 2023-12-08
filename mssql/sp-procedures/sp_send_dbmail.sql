-- https://www.sqlbot.co/blog/sp_send_dbmail-send-mail-from-sql-server-why-not-heres-how

USE msdb

EXEC sp_configure 'show advanced options', 1;  
GO  
RECONFIGURE;  
GO  
EXEC sp_configure 'Database Mail XPs', 1;  
GO  
RECONFIGURE  
GO 

EXEC msdb.dbo.sysmail_add_account_sp  
    @account_name = 'Live.com',  
    @description = 'Mail account for sending outgoing notifications.',  
    @email_address = 'test@example.com',  
    @display_name = 'Automated Mailer',  
    @mailserver_name = 'smtp.live.com',
    @port = 25,
    @enable_ssl = 1,
    @username = 'example@live.com',
    @password = 'example123';
GO

EXEC msdb.dbo.sysmail_add_profile_sp  
    @profile_name = 'Notifications',  
    @description = 'Profile used for sending outgoing notifications using Live.com.' ;  
GO

EXEC msdb.dbo.sysmail_add_profileaccount_sp  
    @profile_name = 'Notifications',  
    @account_name = 'Live.com',  
    @sequence_number = 1;  
GO

EXEC msdb.dbo.sp_send_dbmail  
    @profile_name = 'Notifications',  
    @recipients = 'test@example.com',  
    @body = 'youve sent email from database.',  
    @subject = 'great job',
	@from_address = 'test@example.com',
	@reply_to = 'test@example.com'