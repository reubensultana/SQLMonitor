USE [SQLMonitor]
GO

IF OBJECT_ID('[Monitor].[database_backup_history]') IS NOT NULL
DROP VIEW [Monitor].[database_backup_history]
GO

CREATE VIEW [Monitor].[database_backup_history]
AS
SELECT [ServerName]
      ,[DatabaseName]
      ,[BackupType]
      ,[BackupName]
      ,[LoginName]
      ,[StartDate]
      ,[FinishDate]
      ,[BackupSizeMB]
      ,[SourceServer]
      ,[PhysicalDeviceName]
      ,[LogicalDeviceName]
      ,[ExpirationDate]
      ,[Description]
      ,[RecordStatus]
      ,[RecordCreated]
FROM [Monitor].[DatabaseBackupHistory]
--WHERE [RecordStatus] = 'A'
GO
