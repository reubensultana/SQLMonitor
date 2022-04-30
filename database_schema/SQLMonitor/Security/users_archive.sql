IF NOT EXISTS(SELECT * FROM sys.database_principals WHERE [name]='SqlReports')
    EXEC sp_executesql N'CREATE USER [SqlReports] FOR LOGIN [SqlReports];';
GO
GRANT SELECT, VIEW DEFINITION ON SCHEMA::[Archive] TO [SqlReports]
GO
