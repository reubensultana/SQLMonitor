USE [SQLMonitor]
GO

IF OBJECT_ID ('[Staging].[TR_IndexUsageStats_AI]','TR') IS NOT NULL
   DROP TRIGGER [Staging].[TR_IndexUsageStats_AI] 
GO

IF OBJECT_ID('[Staging].[DatabaseIndexUsageStats]') IS NOT NULL
BEGIN
    DROP TABLE [Staging].[DatabaseIndexUsageStats];
END
GO

CREATE TABLE [Staging].[DatabaseIndexUsageStats](
	[ServerName] [nvarchar](128) NOT NULL,
    [DatabaseName] [nvarchar](128) NOT NULL,
    [ObjectName] [nvarchar](260) NOT NULL,
	[IndexID] [int] NOT NULL,
	[IndexName] [nvarchar](130) NULL,
	[UserSeeks] [bigint] NOT NULL,
	[UserScans] [bigint] NOT NULL,
	[UserLookups] [bigint] NOT NULL,
    [UserUpdates] [bigint] NOT NULL,
    [LastServiceStartDate] [datetime] NOT NULL,
    [RecordStatus] [char] (1) NULL,         -- record status - used to determine if the record is active or not
    [RecordCreated] [datetime2] (0) NULL    -- audit timestamp storing the date and time the record was created (is additional detail necessary?)
) ON [TABLES];
GO

CREATE TRIGGER [Staging].[TR_IndexUsageStats_AI]
   ON [Staging].[DatabaseIndexUsageStats] 
   INSTEAD OF INSERT
AS 
BEGIN
    SET NOCOUNT ON;
    DECLARE @DefaultDate datetime;
    SET @DefaultDate = CAST('2000-01-01' AS datetime);

    MERGE INTO [Monitor].[DatabaseIndexUsageStats] WITH (HOLDLOCK) AS TargetTable
    USING (
        SELECT 
            [ServerName] 
            ,[DatabaseName]
            ,[ObjectName] 
	        ,[IndexID]
	        ,[IndexName]
            ,[UserSeeks]
	        ,[UserScans]
	        ,[UserLookups]
            ,[UserUpdates]
            ,[LastServiceStartDate]
        FROM inserted -- [Staging].[DatabaseIndexUsageStats]
        ) AS SourceTable (
            [ServerName] 
            ,[DatabaseName]
            ,[ObjectName] 
	        ,[IndexID]
	        ,[IndexName]
            ,[UserSeeks]
	        ,[UserScans]
	        ,[UserLookups]
            ,[UserUpdates]
            ,[LastServiceStartDate]
        )
    ON TargetTable.[ServerName] = SourceTable.[ServerName]
        AND TargetTable.[DatabaseName] = SourceTable.[DatabaseName]
        AND TargetTable.[ObjectName] = SourceTable.[ObjectName]
        AND TargetTable.[IndexID] = SourceTable.[IndexID]
        AND COALESCE(TargetTable.[IndexName], N'') = COALESCE(SourceTable.[IndexName], N'')
    WHEN MATCHED THEN
	    UPDATE SET 
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
            TargetTable.[UserLookups] = (
CASE 
    -- service not restarted; counters accumulating
    WHEN (SourceTable.[LastServiceStartDate] <= COALESCE(TargetTable.[LastPollDate], @DefaultDate)) THEN (COALESCE(TargetTable.[UserLookups], 0) + (COALESCE(SourceTable.[UserLookups], 0) - COALESCE(TargetTable.[LastPollUserLookups], 0)))
    -- service restarted; counters reset to 0
    WHEN (SourceTable.[LastServiceStartDate] > COALESCE(TargetTable.[LastPollDate], @DefaultDate)) THEN (COALESCE(TargetTable.[UserLookups], 0) + COALESCE(SourceTable.[UserLookups], 0))
    ELSE COALESCE(SourceTable.[UserLookups], 0)
END),
            TargetTable.[UserUpdates] = (
CASE 
    -- service not restarted; counters accumulating
    WHEN (SourceTable.[LastServiceStartDate] <= COALESCE(TargetTable.[LastPollDate], @DefaultDate)) THEN (COALESCE(TargetTable.[UserUpdates], 0) + (COALESCE(SourceTable.[UserUpdates], 0) - COALESCE(TargetTable.[LastPollUserUpdates], 0)))
    -- service restarted; counters reset to 0
    WHEN (SourceTable.[LastServiceStartDate] > COALESCE(TargetTable.[LastPollDate], @DefaultDate)) THEN (COALESCE(TargetTable.[UserUpdates], 0) + COALESCE(SourceTable.[UserUpdates], 0))
    ELSE COALESCE(SourceTable.[UserUpdates], 0)
END),
	        TargetTable.[LastPollUserSeeks] = COALESCE(SourceTable.[UserSeeks], 0), 
	        TargetTable.[LastPollUserScans] = COALESCE(SourceTable.[UserScans], 0),
            TargetTable.[LastPollUserLookups] = COALESCE(SourceTable.[UserLookups], 0),
            TargetTable.[LastPollUserUpdates] = COALESCE(SourceTable.[UserUpdates], 0),
            TargetTable.[LastPollDate] = SourceTable.[LastServiceStartDate]

    WHEN NOT MATCHED BY TARGET THEN
	    INSERT (
            [ServerName] 
            ,[DatabaseName]
            ,[ObjectName] 
	        ,[IndexID]
	        ,[IndexName]
            ,[UserSeeks]
	        ,[UserScans]
	        ,[UserLookups]
            ,[UserUpdates]
            ,[LastPollUserSeeks]
	        ,[LastPollUserScans]
            ,[LastPollUserLookups]
            ,[LastPollUserUpdates]
            ,[LastPollDate]
            ) 
        VALUES (
            SourceTable.[ServerName] 
            ,SourceTable.[DatabaseName]
            ,SourceTable.[ObjectName] 
	        ,SourceTable.[IndexID]
	        ,SourceTable.[IndexName]
            ,SourceTable.[UserSeeks]
	        ,SourceTable.[UserScans]
	        ,SourceTable.[UserLookups]
            ,SourceTable.[UserUpdates]
            ,COALESCE(SourceTable.[UserSeeks], 0) 
	        ,COALESCE(SourceTable.[UserScans], 0)
            ,COALESCE(SourceTable.[UserLookups], 0)
            ,COALESCE(SourceTable.[UserUpdates], 0)
            ,SourceTable.[LastServiceStartDate]
            );
END
GO