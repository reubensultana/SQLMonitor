USE [SQLMonitorArchive]
GO

IF OBJECT_ID('[Archive].[DatabaseIndexUsageStats]') IS NOT NULL
BEGIN
    DROP TABLE [Archive].[DatabaseIndexUsageStats];
END
GO

CREATE TABLE [Archive].[DatabaseIndexUsageStats](
	[IndexUsageStatsID] [int] NOT NULL,
	[ServerName] [nvarchar](128) NOT NULL,
    [DatabaseName] [nvarchar](128) NOT NULL,
    [ObjectName] [nvarchar](260) NOT NULL,
	[IndexID] [int] NOT NULL,
	[IndexName] [nvarchar](130) NULL,
	[UserSeeks] [bigint] NOT NULL,
	[UserScans] [bigint] NOT NULL,
	[UserLookups] [bigint] NOT NULL,
    [UserUpdates] [bigint] NOT NULL,
    [LastPollUserSeeks] [bigint] NOT NULL,
	[LastPollUserScans] [bigint] NOT NULL,
	[LastPollUserLookups] [bigint] NOT NULL,
    [LastPollUserUpdates] [bigint] NOT NULL,
    [LastPollDate] [datetime] NOT NULL,
    [RecordStatus] [char] (1) NOT NULL,         -- record status - used to determine if the record is active or not
    [RecordCreated] [datetimeoffset] (7) NOT NULL    -- audit timestamp storing the date and time the record was created (is additional detail necessary?)
) ON [TABLES];


-- clustered index on IndexUsageStatsID
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'[Archive].[DatabaseIndexUsageStats]') AND name = N'PK_IndexUsageStats_Archive')
ALTER TABLE [Archive].[DatabaseIndexUsageStats]
ADD  CONSTRAINT [PK_IndexUsageStats_Archive] PRIMARY KEY CLUSTERED ([IndexUsageStatsID] ASC)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON, IGNORE_DUP_KEY = OFF, ONLINE = OFF, 
    ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [TABLES]
GO


USE [master]
GO