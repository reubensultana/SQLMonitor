USE [SQLMonitor]
GO

IF NOT EXISTS(SELECT 1 FROM sys.schemas WHERE name = 'Monitor')
    EXEC sp_executesql N'CREATE SCHEMA [Monitor] AUTHORIZATION [dbo];';
GO

IF NOT EXISTS(SELECT 1 FROM sys.schemas WHERE name = 'Reporting')
    EXEC sp_executesql N'CREATE SCHEMA [Reporting] AUTHORIZATION [dbo];';
GO

IF NOT EXISTS(SELECT 1 FROM sys.schemas WHERE name = 'Staging')
    EXEC sp_executesql N'CREATE SCHEMA [Staging] AUTHORIZATION [dbo];';
GO

----------
USE [SQLMonitorArchive]
GO

IF NOT EXISTS(SELECT 1 FROM sys.schemas WHERE name = 'Archive')
    EXEC sp_executesql N'CREATE SCHEMA [Archive] AUTHORIZATION [dbo];';
GO

----------
USE [master]
GO
