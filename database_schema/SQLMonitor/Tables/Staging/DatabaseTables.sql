USE [SQLMonitor]
GO

IF OBJECT_ID('[Staging].[DatabaseTables]') IS NOT NULL
BEGIN
    DROP TABLE [Staging].[DatabaseTables];
END
GO

CREATE TABLE [Staging].[DatabaseTables](
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


-- default constraint on RecordStatus = "A"
ALTER TABLE [Staging].[DatabaseTables] ADD CONSTRAINT
	DF_DatabaseTables_RecordStatus DEFAULT 'A' FOR RecordStatus
GO

-- default constraint on RecordCreated = SYSDATETIMEOFFSET()
ALTER TABLE [Staging].[DatabaseTables] ADD CONSTRAINT
	DF_DatabaseTables_RecordCreated DEFAULT SYSDATETIMEOFFSET() FOR RecordCreated
GO


USE [master]
GO
