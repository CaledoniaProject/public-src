DECLARE @sql NVARCHAR(500) -- SQL command to execute

DECLARE sql_cursor CURSOR LOCAL FAST_FORWARD FOR
SELECT 'SET identity_insert ['+s.name+'].['+o.name+'] ON'
FROM sys.objects o
INNER JOIN sys.schemas s on s.schema_id=o.schema_id
WHERE o.[type]='U'
AND EXISTS(SELECT 1 FROM sys.columns WHERE object_id=o.object_id AND is_identity=1)

OPEN sql_cursor
FETCH NEXT FROM sql_cursor INTO @sql

WHILE @@FETCH_STATUS = 0
    BEGIN
        EXECUTE sp_executesql @sql  --> Comment this out to test
        -- PRINT @sql   --> Uncomment to test or if logging is desired
        FETCH NEXT FROM sql_cursor INTO @sql
    END

CLOSE sql_cursor
DEALLOCATE sql_cursor

