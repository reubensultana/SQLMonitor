USE [SQLMonitor]
GO

IF OBJECT_ID('[Monitor].[database_indexusagestats]') IS NOT NULL
DROP VIEW [Monitor].[database_indexusagestats]
GO

CREATE VIEW [Monitor].[database_indexusagestats]
AS
SELECT [ServerName]
    ,[DatabaseName]
    ,[ObjectName]
    ,[IndexID]
    ,[IndexName]
    ,[UserSeeks]
    ,[UserScans]
    ,[UserLookups]
    ,[UserUpdates]
    ,[LastServiceStartDate]
    ,[RecordStatus]
    ,[RecordCreated]
FROM [Staging].[IndexUsageStats]
--WHERE [RecordStatus] = 'A'
GO

/*
NOTE:
In this case an object in the "Staging" schema is used as the VIEW target because we 
wanted to accumulate the results of the data collection rather than appending them.
A trigger has been created on the destination object to achieve this functionality.
*/
