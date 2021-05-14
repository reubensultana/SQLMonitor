USE [SQLMonitor]
GO

IF OBJECT_ID ('[Staging].[TR_MissingIndexStats_AI]','TR') IS NOT NULL
   DROP TRIGGER [Staging].[TR_MissingIndexStats_AI] 
GO

IF OBJECT_ID('[Staging].[DatabaseMissingIndexStats]') IS NOT NULL
BEGIN
    DROP TABLE [Staging].[DatabaseMissingIndexStats];
END
GO

CREATE TABLE [Staging].[DatabaseMissingIndexStats](
	[ServerName] [nvarchar](128) NOT NULL,
    [DatabaseName] [nvarchar](128) NOT NULL,
    [ObjectName] [nvarchar](260),
    [EqualityColumns] [nvarchar](4000) NULL,
	[InequalityColumns] [nvarchar](4000) NULL,
	[IncludedColumns] [nvarchar](4000) NULL,
	[UniqueCompiles] [bigint] NOT NULL,
	[UserSeeks] [bigint] NOT NULL,
	[UserScans] [bigint] NOT NULL,
	[AvgTotalUserCost] [numeric] (15,2) NULL,
	[AvgUserImpact] [numeric] (5,2) NULL,
    [LastServiceStartDate] [datetime] NOT NULL,
    [RecordStatus] [char] (1) NULL,         -- record status - used to determine if the record is active or not
    [RecordCreated] [datetime2] (0) NULL    -- audit timestamp storing the date and time the record was created (is additional detail necessary?)
) ON [TABLES];
GO

CREATE TRIGGER [Staging].[TR_MissingIndexStats_AI]
   ON [Staging].[DatabaseMissingIndexStats] 
   INSTEAD OF INSERT
AS 
BEGIN
    SET NOCOUNT ON;
	DECLARE @DefaultDate datetime;
    SET @DefaultDate = CAST('2000-01-01' AS datetime);

    MERGE INTO [Monitor].[DatabaseMissingIndexStats] WITH (HOLDLOCK) AS TargetTable
    USING (
        SELECT 
            [ServerName] 
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
        FROM inserted -- [Staging].[DatabaseMissingIndexStats]
        ) AS SourceTable (
            [ServerName] 
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
        )
    ON TargetTable.[ServerName] = SourceTable.[ServerName]
        AND TargetTable.[DatabaseName] = SourceTable.[DatabaseName]
        AND TargetTable.[ObjectName] = SourceTable.[ObjectName]
        AND COALESCE(TargetTable.[EqualityColumns], N'') = COALESCE(SourceTable.[EqualityColumns], N'')
        AND COALESCE(TargetTable.[InequalityColumns], N'') = COALESCE(SourceTable.[InequalityColumns], N'')
        AND COALESCE(TargetTable.[IncludedColumns], N'') = COALESCE(SourceTable.[IncludedColumns], N'')
    WHEN MATCHED THEN
	    UPDATE SET 
			TargetTable.[UniqueCompiles] =   (
CASE 
    -- service not restarted; counters accumulating
    WHEN (SourceTable.[LastServiceStartDate] <= COALESCE(TargetTable.[LastPollDate], @DefaultDate)) THEN (COALESCE(TargetTable.[UniqueCompiles], 0) + (COALESCE(SourceTable.[UniqueCompiles], 0) - COALESCE(TargetTable.[LastPollUniqueCompiles], 0)))
    -- service restarted; counters reset to 0
    WHEN (SourceTable.[LastServiceStartDate] > COALESCE(TargetTable.[LastPollDate], @DefaultDate)) THEN (COALESCE(TargetTable.[UniqueCompiles], 0) + COALESCE(SourceTable.[UniqueCompiles], 0))
    ELSE COALESCE(SourceTable.[UniqueCompiles], 0)
END),
            TargetTable.[UserSeeks] =   (
CASE 
    -- service not restarted; counters accumulating
    WHEN (SourceTable.[LastServiceStartDate] <= COALESCE(TargetTable.[LastPollDate], @DefaultDate)) THEN (COALESCE(TargetTable.[UserSeeks], 0) + (COALESCE(SourceTable.[UserSeeks], 0) - COALESCE(TargetTable.[LastPollUserSeeks], 0)))
    -- service restarted; counters reset to 0
    WHEN (SourceTable.[LastServiceStartDate] > COALESCE(TargetTable.[LastPollDate], @DefaultDate)) THEN (COALESCE(TargetTable.[UserSeeks], 0) + COALESCE(SourceTable.[UserSeeks], 0))
    ELSE COALESCE(SourceTable.[UserSeeks], 0)
END),
            TargetTable.[UserScans] =   (
CASE 
    -- service not restarted; counters accumulating
    WHEN (SourceTable.[LastServiceStartDate] <= COALESCE(TargetTable.[LastPollDate], @DefaultDate)) THEN (COALESCE(TargetTable.[UserScans], 0) + (COALESCE(SourceTable.[UserScans], 0) - COALESCE(TargetTable.[LastPollUserScans], 0)))
    -- service restarted; counters reset to 0
    WHEN (SourceTable.[LastServiceStartDate] > COALESCE(TargetTable.[LastPollDate], @DefaultDate)) THEN (COALESCE(TargetTable.[UserScans], 0) + COALESCE(SourceTable.[UserScans], 0))
    ELSE COALESCE(SourceTable.[UserScans], 0)
END),       
			TargetTable.[LastPollUniqueCompiles] = COALESCE(SourceTable.[UniqueCompiles], 0),
			TargetTable.[LastPollUserSeeks] = COALESCE(SourceTable.[UserSeeks], 0),
            TargetTable.[LastPollUserScans] = COALESCE(SourceTable.[UserScans], 0),
            
			TargetTable.[AvgTotalUserCost] = SourceTable.[AvgTotalUserCost],
            TargetTable.[AvgUserImpact] = SourceTable.[AvgUserImpact],
            TargetTable.[LastPollDate] = SourceTable.[LastServiceStartDate]

    WHEN NOT MATCHED BY TARGET THEN
	    INSERT (
            [ServerName] 
            ,[DatabaseName]
	        ,[ObjectName]
            ,[EqualityColumns]
            ,[InequalityColumns]
            ,[IncludedColumns]
            ,[UniqueCompiles]
            ,[UserSeeks]
            ,[UserScans]
			,[LastPollUniqueCompiles]
            ,[LastPollUserSeeks]
            ,[LastPollUserScans]
            ,[AvgTotalUserCost]
            ,[AvgUserImpact]
            ,[LastPollDate]
            ) 
        VALUES (
            SourceTable.[ServerName] 
            ,SourceTable.[DatabaseName]
	        ,SourceTable.[ObjectName]
            ,SourceTable.[EqualityColumns]
            ,SourceTable.[InequalityColumns]
            ,SourceTable.[IncludedColumns]
            ,SourceTable.[UniqueCompiles]
            ,SourceTable.[UserSeeks]
            ,SourceTable.[UserScans]
			,COALESCE(SourceTable.[UniqueCompiles], 0)
            ,COALESCE(SourceTable.[UserSeeks], 0)
            ,COALESCE(SourceTable.[UserScans], 0)
            ,SourceTable.[AvgTotalUserCost]
            ,SourceTable.[AvgUserImpact]
            ,SourceTable.[LastServiceStartDate]
            );
END
GO
