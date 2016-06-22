USE [SQLMonitor]
GO

IF OBJECT_ID('[Monitor].[database_configurations]') IS NOT NULL
DROP VIEW [Monitor].[database_configurations]
GO

CREATE VIEW [Monitor].[database_configurations]
AS
SELECT [ServerName]
    ,[DatabaseName]
    ,[FileID]
    ,[FileType]
    ,[FileName]
    ,[FilePath]
    ,[State]
    ,[IsReadOnly]
    ,[SizeMB]
    ,[MaxSizeMB]
    ,[GrowthMB]
    ,[IsPercentGrowth]
    ,[RecordStatus] 
    ,[RecordCreated]
FROM [Monitor].[DatabaseConfigurations]
-- WHERE [RecordStatus] = 'A'
GO
