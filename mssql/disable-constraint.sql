USE YOUR_DB
EXEC sp_msforeachtable "ALTER TABLE ? NOCHECK CONSTRAINT all"

-- 或者单独关闭
ALTER TABLE dbo.YOUR_TABLE NOCHECK CONSTRAINT ALL
