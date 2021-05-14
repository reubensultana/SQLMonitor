USE [SQLMonitor]
GO

IF OBJECT_ID('[Monitor].[DatabaseMissingIndexStats]') IS NOT NULL
BEGIN
    DROP TABLE [Monitor].[DatabaseMissingIndexStats];
END
GO

CREATE TABLE [Monitor].[DatabaseMissingIndexStats](
	[MissingIndexStatsID] [int] IDENTITY(-2147483648,1) NOT NULL,
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
) ON [TABLES];


-- clustered index on MissingIndexStatsID
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'[Monitor].[DatabaseMissingIndexStats]') AND name = N'PK_MissingIndexStats')
ALTER TABLE [Monitor].[DatabaseMissingIndexStats]
ADD  CONSTRAINT [PK_MissingIndexStats] PRIMARY KEY CLUSTERED ([MissingIndexStatsID] ASC)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON, IGNORE_DUP_KEY = OFF, ONLINE = OFF, 
    ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [TABLES]
GO


-- default constraint on RecordStatus = "A"
ALTER TABLE [Monitor].[DatabaseMissingIndexStats] ADD CONSTRAINT
	DF_MissingIndexStats_RecordStatus DEFAULT 'A' FOR RecordStatus
GO
-- check constraint on RecordStatus - allowed values "A", "D", "H"
ALTER TABLE [Monitor].[DatabaseMissingIndexStats] ADD CONSTRAINT
	CK_MissingIndexStats_RecordStatus CHECK (RecordStatus LIKE '[ADH]')
GO

-- default constraint on RecordCreated = SYSDATETIMEOFFSET()
ALTER TABLE [Monitor].[DatabaseMissingIndexStats] ADD CONSTRAINT
	DF_MissingIndexStats_RecordCreated DEFAULT SYSDATETIMEOFFSET() FOR RecordCreated
GO


USE [master]
GO