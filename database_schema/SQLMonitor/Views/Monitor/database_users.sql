USE [SQLMonitor]
GO

IF OBJECT_ID('[Monitor].[database_users]') IS NOT NULL
DROP VIEW [Monitor].[database_users]
GO

CREATE VIEW [Monitor].[database_users]
AS
SELECT [ServerName]
      ,[DatabaseName]
      ,[PrincipalName]
      ,[db_accessadmin]
      ,[db_backupoperator]
      ,[db_ddladmin]
      ,[db_owner]
      ,[db_securityadmin]
      ,[SecurablesPermissions]
      ,[RecordStatus]
      ,[RecordCreated]
FROM [Monitor].[DatabaseUsers]
--WHERE [RecordStatus] = 'A'
GO
