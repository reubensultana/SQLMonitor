USE [SQLMonitor]
GO

IF OBJECT_ID('[Monitor].[server_freespace]') IS NOT NULL
DROP VIEW [Monitor].[server_freespace]
GO

CREATE VIEW [Monitor].[server_freespace]
AS
SELECT [ServerName]
      ,[Drive]
      ,[FreeMB]
      ,[RecordStatus]
      ,[RecordCreated]
FROM [Monitor].[ServerFreeSpace]
--WHERE [RecordStatus] = 'A'
GO
