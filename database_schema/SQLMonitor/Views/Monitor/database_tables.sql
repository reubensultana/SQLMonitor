USE [SQLMonitor]
GO

IF OBJECT_ID('[Monitor].[database_tables]') IS NOT NULL
DROP VIEW [Monitor].[database_tables]
GO

CREATE VIEW [Monitor].[database_tables]
AS
SELECT [ServerName]
      ,[DatabaseName]
      ,[TableName]
      ,[RowCount]
      ,[ReservedKB]
      ,[DataSizeKB]
      ,[IndexSizeKB]
      ,[UnusedSpaceKB]
      ,[RecordStatus]
      ,[RecordCreated]
FROM [Monitor].[DatabaseTables]
--WHERE [RecordStatus] = 'A'
GO
