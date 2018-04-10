USE [SQLMonitorArchive]
GO

IF OBJECT_ID('[Archive].[DatabaseTables]') IS NOT NULL
BEGIN
    DROP TABLE [Archive].[DatabaseTables];
END
GO

CREATE TABLE [Archive].[DatabaseTables](
    [DatabaseTableID] [int] NOT NULL,
	[ServerName] [nvarchar](128) NOT NULL,
    [DatabaseName] [nvarchar](128) NOT NULL,
    [TableName] [nvarchar](128) NOT NULL, 
    [RowCount] [bigint] NOT NULL, 
    [ReservedKB] [bigint] NOT NULL, 
    [DataSizeKB] [bigint] NOT NULL,
    [IndexSizeKB] [bigint] NOT NULL,
    [UnusedSpaceKB] [bigint] NOT NULL,
    [RecordStatus] [char] (1) NOT NULL,         -- record status - used to determine if the record is active or not
    [RecordCreated] [datetime2] (0) NOT NULL    -- audit timestamp storing the date and time the record was created (is additional detail necessary?)
) ON [TABLES]
GO


-- clustered index on DatabaseTableID
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'[Archive].[DatabaseTables]') AND name = N'PK_DatabaseTables_Archive')
ALTER TABLE [Archive].[DatabaseTables]
ADD  CONSTRAINT [PK_DatabaseTables_Archive] PRIMARY KEY CLUSTERED ([DatabaseTableID] ASC)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON, IGNORE_DUP_KEY = OFF, ONLINE = OFF, 
    ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [TABLES]
GO


USE [master]
GO
