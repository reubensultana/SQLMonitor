USE [SQLMonitor]
GO

IF OBJECT_ID('[Monitor].[server_servers]') IS NOT NULL
DROP VIEW [Monitor].[server_servers]
GO

CREATE VIEW [Monitor].[server_servers]
AS
SELECT [ServerName]
      ,[ServerID]
      ,[LinkedServer]
      ,[ProductName]
      ,[ProviderName]
      ,[DataSource]
      ,[ProviderString]
      ,[CatalogConnection]
      ,[RecordStatus]
      ,[RecordCreated]
FROM [Monitor].[ServerServers]
--WHERE [RecordStatus] = 'A'
GO
