USE [SQLMonitorArchive]
GO

IF OBJECT_ID('[Archive].[DatabaseConfigurations]') IS NOT NULL
BEGIN
    DROP TABLE [Archive].[DatabaseConfigurations];
END
GO

CREATE TABLE [Archive].[DatabaseConfigurations](
    [DatabaseConfigID] [int] NOT NULL,
	[ServerName] [nvarchar](128) NOT NULL,
    [DatabaseName] [nvarchar](128) NOT NULL,
    [FileID] [int] NOT NULL,
    [FileType] [nvarchar](60) NOT NULL,
    [FileName] [nvarchar](128) NOT NULL,
    [FilePath] [nvarchar](260) NOT NULL,
    [State] [nvarchar](60) NOT NULL,
    [IsReadOnly] [bit] NOT NULL,
    [SizeMB] [numeric](15,2) NOT NULL,
    [MaxSizeMB] [numeric](15,0) NOT NULL,
    [GrowthMB] [numeric](15,0) NOT NULL,
    [IsPercentGrowth] [bit] NOT NULL,
    [RecordStatus] [char] (1) NOT NULL,        -- record status - used to determine if the record is active or not
    [RecordCreated] [datetime2] (0) NOT NULL   -- audit timestamp storing the date and time the record was created (is additional detail necessary?)
) ON [TABLES]
GO


-- clustered index on DatabaseConfigID
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'[Archive].[DatabaseConfigurations]') AND name = N'PK_DatabaseConfigurations_Archive')
ALTER TABLE [Archive].[DatabaseConfigurations]
ADD  CONSTRAINT [PK_DatabaseConfigurations_Archive] PRIMARY KEY CLUSTERED ([DatabaseConfigID] ASC)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON, IGNORE_DUP_KEY = OFF, ONLINE = OFF, 
    ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [TABLES]
GO


USE [master]
GO
