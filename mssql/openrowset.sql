
sp_configure 'show advanced options', 1;
RECONFIGURE;
GO
sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;
GO

SELECT * FROM OPENROWSET(
    'SQLNCLI',
    'server=127.0.0.1,1433;database=xxx;uid=sa;pwd=xxx;',
    'SELECT * from dbo.TABLE_TEST'
);

