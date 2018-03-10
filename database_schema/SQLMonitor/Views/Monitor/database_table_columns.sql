USE [SQLMonitor]
GO

IF OBJECT_ID('[Monitor].[database_table_columns]') IS NOT NULL
DROP VIEW [Monitor].[database_table_columns]
GO

CREATE VIEW [Monitor].[database_table_columns]
AS
SELECT [ServerName]
      ,[DatabaseName]
      ,[TableSchema]
      ,[TableName]
      ,[ColumnName]
      ,[OrdinalPosition]
      ,[DataType]
      ,[LengthOrPrecision]
      ,[RecordStatus]
      ,[RecordCreated]
FROM [Monitor].[DatabaseTableColumns]
--WHERE [RecordStatus] = 'A'
GO
