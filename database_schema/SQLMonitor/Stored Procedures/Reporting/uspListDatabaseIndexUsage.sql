USE [SQLMonitor]
GO

IF OBJECT_ID(N'[Reporting].[uspListDatabaseIndexUsage]') IS NOT NULL
DROP PROCEDURE [Reporting].[uspListDatabaseIndexUsage]
GO

CREATE PROCEDURE [Reporting].[uspListDatabaseIndexUsage] 
    @ServerName nvarchar(128) = '%',
    @DatabaseName nvarchar(128) = '%'
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON;
    SELECT [ServerName]
        ,[DatabaseName]
        ,[ObjectName]
        ,[IndexID]
        ,[IndexName]
        ,[UserSeeks]
        ,[UserScans]
        ,[UserLookups]
        ,[UserUpdates]
        ,[LastPollDate]
    FROM [Monitor].[IndexUsageStats]
    WHERE [ServerName] LIKE @ServerName
    AND [DatabaseName] LIKE @DatabaseName
    AND [RecordStatus] = 'A'
    ORDER BY 
        [ServerName]
        ,[DatabaseName]
        ,[ObjectName]
        ,[IndexID]
        ,[IndexName];
END
GO

-- EXEC [SQLMonitor].[Reporting].[uspListDatabaseIndexUsage] 


USE [master]
GO
