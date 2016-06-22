USE [SQLMonitor]
GO

IF OBJECT_ID('[Monitor].[server_configurations]') IS NOT NULL
DROP VIEW [Monitor].[server_configurations]
GO

CREATE VIEW [Monitor].[server_configurations]
AS
SELECT [ServerName]
      ,[ConfigID]
      ,[ConfigName]
      ,[ValueSet]
      ,[ValueInUse]
      ,[RecordStatus]
      ,[RecordCreated]
FROM [Monitor].[ServerConfigurations]
--WHERE [RecordStatus] = 'A'
GO
