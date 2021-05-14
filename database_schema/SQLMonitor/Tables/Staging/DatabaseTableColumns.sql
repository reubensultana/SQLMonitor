USE [SQLMonitor]
GO

IF OBJECT_ID('[Staging].[DatabaseTableColumns]') IS NOT NULL
BEGIN
    DROP TABLE [Staging].[DatabaseTableColumns];
END
GO

CREATE TABLE [Staging].[DatabaseTableColumns](
	[ServerName] [nvarchar](128) NOT NULL,
    [DatabaseName] [nvarchar](128) NOT NULL,
    [TableSchema] [nvarchar](128) NOT NULL, 
    [TableName] [nvarchar](128) NOT NULL, 
    [ColumnName] [nvarchar](128) NOT NULL, 
    [OrdinalPosition] [int] NOT NULL,
    [DataType] [nvarchar](128) NULL, 
    [LengthOrPrecision] [nvarchar](128) NULL,
    [RecordStatus] [char] (1) NOT NULL,         -- record status - used to determine if the record is active or not
    [RecordCreated] [datetimeoffset] (7) NOT NULL    -- audit timestamp storing the date and time the record was created (is additional detail necessary?)
) ON [TABLES]
GO


-- default constraint on RecordStatus = "A"
ALTER TABLE [Staging].[DatabaseTableColumns] ADD CONSTRAINT
	DF_DatabaseTableColumns_RecordStatus DEFAULT 'A' FOR RecordStatus
GO

-- default constraint on RecordCreated = SYSDATETIMEOFFSET()
ALTER TABLE [Staging].[DatabaseTableColumns] ADD CONSTRAINT
	DF_DatabaseTableColumns_RecordCreated DEFAULT SYSDATETIMEOFFSET() FOR RecordCreated
GO


USE [master]
GO
