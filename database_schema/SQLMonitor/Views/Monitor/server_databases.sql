USE [SQLMonitor]
GO

IF OBJECT_ID('[Monitor].[server_databases]') IS NOT NULL
DROP VIEW [Monitor].[server_databases]
GO

CREATE VIEW [Monitor].[server_databases]
AS
SELECT [ServerName]
      ,[DatabaseName]
      ,[DatabaseOwner]
      ,[CreateDate]
      ,[CompatibilityLevel]
      ,[CollationName]
      ,[UserAccess]
      ,[IsReadOnly]
      ,[IsAutoClose]
      ,[IsAutoShrink]
      ,[State]
      ,[IsInStandby]
      ,[RecoveryModel]
      ,[PageVerifyOption]
      ,[IsFullTextEnabled]
      ,[IsTrustworthy]
      ,[RecordStatus]
      ,[RecordCreated]
FROM [Monitor].[ServerDatabases]
--WHERE [RecordStatus] = 'A'
GO
