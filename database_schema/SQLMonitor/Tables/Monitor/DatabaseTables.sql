USE [SQLMonitor]
GO

IF OBJECT_ID('[Monitor].[DatabaseTables]') IS NOT NULL
BEGIN
    DROP TABLE [Monitor].[DatabaseTables];
END
GO

CREATE TABLE [Monitor].[DatabaseTables](
    [DatabaseTableID] [int] IDENTITY(-2147483648,1) NOT NULL,
	[ServerName] [nvarchar](128) NOT NULL,
    [DatabaseName] [nvarchar](128) NOT NULL,
    [TableName] [nvarchar](128) NOT NULL, 
    [RowCount] [bigint] NOT NULL, 
    [ReservedKB] [bigint] NOT NULL, 
    [DataSizeKB] [bigint] NOT NULL,
    [IndexSizeKB] [bigint] NOT NULL,
    [UnusedSpaceKB] [bigint] NOT NULL,
    [RecordStatus] [char] (1) NOT NULL,         -- record status - used to determine if the record is active or not
    [RecordCreated] [datetimeoffset] (7) NOT NULL    -- audit timestamp storing the date and time the record was created (is additional detail necessary?)
) ON [TABLES]
GO


-- clustered index on DatabaseTableID
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'[Monitor].[DatabaseTables]') AND name = N'PK_DatabaseTables')
ALTER TABLE [Monitor].[DatabaseTables]
ADD  CONSTRAINT [PK_DatabaseTables] PRIMARY KEY CLUSTERED ([DatabaseTableID] ASC)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON, IGNORE_DUP_KEY = OFF, ONLINE = OFF, 
    ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [TABLES]
GO


-- default constraint on RecordStatus = "A"
ALTER TABLE [Monitor].[DatabaseTables] ADD CONSTRAINT
	DF_DatabaseTables_RecordStatus DEFAULT 'A' FOR RecordStatus
GO
-- check constraint on RecordStatus - allowed values "A", "D", "H"
ALTER TABLE [Monitor].[DatabaseTables] ADD CONSTRAINT
	CK_DatabaseTables_RecordStatus CHECK (RecordStatus LIKE '[ADH]')
GO

-- default constraint on RecordCreated = SYSDATETIMEOFFSET()
ALTER TABLE [Monitor].[DatabaseTables] ADD CONSTRAINT
	DF_DatabaseTables_RecordCreated DEFAULT SYSDATETIMEOFFSET() FOR RecordCreated
GO


USE [master]
GO
