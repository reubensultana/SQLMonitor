USE [SQLMonitor]
GO

IF OBJECT_ID(N'[Reporting].[uspListDatabaseMissingIndex]') IS NOT NULL
DROP PROCEDURE [Reporting].[uspListDatabaseMissingIndex]
GO

CREATE PROCEDURE [Reporting].[uspListDatabaseMissingIndex] 
    @ServerName nvarchar(128) = '%',
    @DatabaseName nvarchar(128) = '%'
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON;
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
      ,[LastPollDate]
    FROM [Monitor].[MissingIndexStats]
    WHERE [ServerName] LIKE @ServerName
    AND [DatabaseName] LIKE @DatabaseName
    AND [RecordStatus] = 'A'
    ORDER BY 
        [ServerName]
        ,[DatabaseName]
        ,[AvgUserImpact] DESC
        ,[ObjectName];
END
GO

-- EXEC [SQLMonitor].[Reporting].[uspListDatabaseMissingIndex] 


USE [master]
GO
