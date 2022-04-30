IF OBJECT_ID('[Archive].[DatabaseMissingIndexStats]') IS NOT NULL
DROP TABLE [Archive].[DatabaseMissingIndexStats];
GO

CREATE TABLE [Archive].[DatabaseMissingIndexStats](
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
    [RecordCreated] [datetimeoffset] (7) NOT NULL    -- audit timestamp storing the date and time the record was created (is additional detail necessary?)
)
GO


-- clustered index on MissingIndexStatsID
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'[Archive].[DatabaseMissingIndexStats]') AND name = N'PK_MissingIndexStats_Archive')
ALTER TABLE [Archive].[DatabaseMissingIndexStats]
ADD  CONSTRAINT [PK_MissingIndexStats_Archive] PRIMARY KEY CLUSTERED ([MissingIndexStatsID] ASC)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON, IGNORE_DUP_KEY = OFF, ONLINE = OFF, 
    ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100)
GO
