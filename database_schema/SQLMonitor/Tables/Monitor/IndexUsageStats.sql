USE [SQLMonitor]
GO

IF OBJECT_ID('[Monitor].[IndexUsageStats]') IS NOT NULL
BEGIN
    DROP TABLE [Monitor].[IndexUsageStats];
END
GO

CREATE TABLE [Monitor].[IndexUsageStats](
	[IndexUsageStatsID] [int] IDENTITY(-2147483648,1) NOT NULL,
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
    [RecordCreated] [datetime2] (0) NOT NULL    -- audit timestamp storing the date and time the record was created (is additional detail necessary?)
) ON [TABLES];


-- clustered index on IndexUsageStatsID
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'[Monitor].[IndexUsageStats]') AND name = N'PK_IndexUsageStats')
ALTER TABLE [Monitor].[IndexUsageStats]
ADD  CONSTRAINT [PK_IndexUsageStats] PRIMARY KEY CLUSTERED ([IndexUsageStatsID] ASC)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON, IGNORE_DUP_KEY = OFF, ONLINE = OFF, 
    ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [TABLES]
GO


-- default constraint on RecordStatus = "A"
ALTER TABLE [Monitor].[IndexUsageStats] ADD CONSTRAINT
	DF_IndexUsageStats_RecordStatus DEFAULT 'A' FOR RecordStatus
GO
-- check constraint on RecordStatus - allowed values "A", "D", "H"
ALTER TABLE [Monitor].[IndexUsageStats] ADD CONSTRAINT
	CK_IndexUsageStats_RecordStatus CHECK (RecordStatus LIKE '[ADH]')
GO

-- default constraint on RecordCreated = CURRENT_TIMESTAMP
ALTER TABLE [Monitor].[IndexUsageStats] ADD CONSTRAINT
	DF_IndexUsageStats_RecordCreated DEFAULT CURRENT_TIMESTAMP FOR RecordCreated
GO


USE [master]
GO