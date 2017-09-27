USE [SQLMonitor]
GO

IF OBJECT_ID('[Monitor].[MissingIndexStats]') IS NOT NULL
BEGIN
    DROP TABLE [Monitor].[MissingIndexStats];
END
GO

CREATE TABLE [Monitor].[MissingIndexStats](
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
    [RecordCreated] [datetime2] (0) NOT NULL    -- audit timestamp storing the date and time the record was created (is additional detail necessary?)
) ON [TABLES];


-- clustered index on MissingIndexStatsID
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'[Monitor].[MissingIndexStats]') AND name = N'PK_MissingIndexStats')
ALTER TABLE [Monitor].[MissingIndexStats]
ADD  CONSTRAINT [PK_MissingIndexStats] PRIMARY KEY CLUSTERED ([MissingIndexStatsID] ASC)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON, IGNORE_DUP_KEY = OFF, ONLINE = OFF, 
    ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [TABLES]
GO


-- default constraint on RecordStatus = "A"
ALTER TABLE [Monitor].[MissingIndexStats] ADD CONSTRAINT
	DF_MissingIndexStats_RecordStatus DEFAULT 'A' FOR RecordStatus
GO
-- check constraint on RecordStatus - allowed values "A", "D", "H"
ALTER TABLE [Monitor].[MissingIndexStats] ADD CONSTRAINT
	CK_MissingIndexStats_RecordStatus CHECK (RecordStatus LIKE '[ADH]')
GO

-- default constraint on RecordCreated = CURRENT_TIMESTAMP
ALTER TABLE [Monitor].[MissingIndexStats] ADD CONSTRAINT
	DF_MissingIndexStats_RecordCreated DEFAULT CURRENT_TIMESTAMP FOR RecordCreated
GO


USE [master]
GO