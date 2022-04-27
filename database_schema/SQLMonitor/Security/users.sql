USE [master]
GO
IF NOT EXISTS(SELECT * FROM sys.server_principals WHERE [name]='SqlReports')
    EXEC sp_executesql N'CREATE LOGIN [SqlReports] WITH PASSWORD=''P@ssw0rd1!'', CHECK_POLICY=ON, CHECK_EXPIRATION=OFF;';
GO
----------
USE [SQLMonitor]
GO
IF NOT EXISTS(SELECT * FROM sys.database_principals WHERE [name]='SqlReports')
    EXEC sp_executesql N'CREATE USER [SQLReports] FOR LOGIN [SqlReports];';
GO
GRANT SELECT, VIEW DEFINITION ON SCHEMA::[Monitor] TO [SqlReports]
GO
GRANT SELECT, VIEW DEFINITION ON SCHEMA::[Archive] TO [SqlReports]
GO
GRANT EXECUTE ON SCHEMA::[Reporting] TO [SqlReports]
GO
----------
USE [SQLMonitorArchive]
GO
IF NOT EXISTS(SELECT * FROM sys.database_principals WHERE [name]='SqlReports')
    EXEC sp_executesql N'CREATE USER [SqlReports] FOR LOGIN [SqlReports];';
GO
GRANT SELECT, VIEW DEFINITION ON SCHEMA::[Archive] TO [SqlReports]
GO



----------
USE [SQLMonitor]
GO
CREATE USER [SqlMonitorEncryption] WITHOUT LOGIN
GO
-- double-check if CONTROL is really necessary, even though this is a User without Login
GRANT CONTROL ON CERTIFICATE::[SQLServersMonitor] TO [SqlMonitorEncryption]
GO

----------
USE [master]
GO
