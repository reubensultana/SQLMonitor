USE [master]
GO
IF NOT EXISTS(SELECT * FROM sys.server_principals WHERE [name]='SQLReports')
    EXEC sp_executesql N'CREATE LOGIN [SQLReports] WITH PASSWORD=''P@ssw0rd'', CHECK_POLICY=ON, CHECK_EXPIRATION=OFF;';
GO
----------
USE [SQLMonitor]
GO
IF NOT EXISTS(SELECT * FROM sys.database_principals WHERE [name]='SQLReports')
    EXEC sp_executesql N'CREATE USER [SQLReports] FOR LOGIN [SQLReports];';
GO
GRANT SELECT, VIEW DEFINITION ON SCHEMA::[Monitor] TO [SQLReports]
GO
GRANT SELECT, VIEW DEFINITION ON SCHEMA::[Archive] TO [SQLReports]
GO
GRANT EXECUTE ON SCHEMA::[Reporting] TO [SQLReports]
GO
----------
USE [SQLMonitorArchive]
GO
IF NOT EXISTS(SELECT * FROM sys.database_principals WHERE [name]='SQLReports')
    EXEC sp_executesql N'CREATE USER [SQLReports] FOR LOGIN [SQLReports];';
GO
GRANT SELECT, VIEW DEFINITION ON SCHEMA::[Archive] TO [SQLReports]
GO


----------
USE [master]
GO
