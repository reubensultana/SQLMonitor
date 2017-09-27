USE [SQLMonitor]
GO

IF OBJECT_ID('[Monitor].[database_missingindexstats]') IS NOT NULL
DROP VIEW [Monitor].[database_missingindexstats]
GO

CREATE VIEW [Monitor].[database_missingindexstats]
AS
SELECT [ServerName]
    ,[DatabaseName]
    ,[ObjectName]
    ,[EqualityColumns]
    ,[InequalityColumns]
    ,[IncludedColumns]
    ,[UniqueCompiles]
    ,[UserSeeks]
    ,[UserScans]
    ,[AvgTotalUserCost]
    ,[AvgUserImpact]
    ,[LastServiceStartDate]
    ,[RecordStatus]
    ,[RecordCreated]
FROM [Staging].[MissingIndexStats]
--WHERE [RecordStatus] = 'A'
GO

/*
NOTE:
In this case an object in the "Staging" schema is used as the VIEW target because we 
wanted to accumulate the results of the data collection rather than appending them.
A trigger has been created on the destination object to achieve this functionality.
*/
