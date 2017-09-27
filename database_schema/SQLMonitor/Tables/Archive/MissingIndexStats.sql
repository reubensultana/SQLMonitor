USE [SQLMonitor]
GO

IF OBJECT_ID('[Archive].[MissingIndexStats]') IS NOT NULL
BEGIN
    DROP TABLE [Archive].[MissingIndexStats];
END
GO

CREATE TABLE [Archive].[MissingIndexStats](
	[MissingIndexStatsID] [int] NOT NULL,
	[ServerName] [nvarchar](128) NOT NULL,
    [DatabaseName] [nvarchar](128) NOT NULL,
    [ObjectName] [nvarchar](260),
    [EqualityColumns] [nvarchar](4000) NULL,
	[InequalityColumns] [nvarchar](4000) NULL,
	[IncludedColumns] [nvarchar](4000) NULL,
	[UniqueCompiles] [bigint] NOT NULL,
	[UserSeeks] [bigint] NOT NULL,
	[UserScans] [bigint] NOT NULL,
	[LastPollUniqueCompiles] [bigint] NOT NULL,
	[LastPollUserSeeks] [bigint] NOT NULL,
	[LastPollUserScans] [bigint] NOT NULL,
	[AvgTotalUserCost] [numeric] (15,2) NULL,
	[AvgUserImpact] [numeric] (5,2) NULL,
    [LastPollDate] [datetime] NOT NULL,
    [RecordStatus] [char] (1) NOT NULL,         -- record status - used to determine if the record is active or not
    [RecordCreated] [datetime2] (0) NOT NULL    -- audit timestamp storing the date and time the record was created (is additional detail necessary?)
) ON [TABLES];


-- clustered index on MissingIndexStatsID
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'[Archive].[MissingIndexStats]') AND name = N'PK_MissingIndexStats_Archive')
ALTER TABLE [Archive].[MissingIndexStats]
ADD  CONSTRAINT [PK_MissingIndexStats_Archive] PRIMARY KEY CLUSTERED ([MissingIndexStatsID] ASC)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON, IGNORE_DUP_KEY = OFF, ONLINE = OFF, 
    ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [TABLES]
GO


USE [master]
GO