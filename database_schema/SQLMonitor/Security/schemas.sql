USE [SQLMonitor]
GO

IF NOT EXISTS(SELECT 1 FROM sys.schemas WHERE name = 'Monitor')
    EXEC sp_executesql N'CREATE SCHEMA [Monitor] AUTHORIZATION [dbo];';
GO

IF NOT EXISTS(SELECT 1 FROM sys.schemas WHERE name = 'Reporting')
    EXEC sp_executesql N'CREATE SCHEMA [Reporting] AUTHORIZATION [dbo];';
GO


USE [master]
GO
