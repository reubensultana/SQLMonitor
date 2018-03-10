USE [SQLMonitor]
GO

IF OBJECT_ID('[Monitor].[DatabaseTableColumns]') IS NOT NULL
BEGIN
    DROP TABLE [Monitor].[DatabaseTableColumns];
END
GO

CREATE TABLE [Monitor].[DatabaseTableColumns](
    [DatabaseTableColumnID] [int] IDENTITY(-2147483648,1) NOT NULL,
	[ServerName] [nvarchar](128) NOT NULL,
    [DatabaseName] [nvarchar](128) NOT NULL,
    [TableSchema] [nvarchar](128) NOT NULL, 
    [TableName] [nvarchar](128) NOT NULL, 
    [ColumnName] [nvarchar](128) NOT NULL, 
    [OrdinalPosition] [int] NOT NULL,
    [DataType] [nvarchar](128) NULL, 
    [LengthOrPrecision] [nvarchar](128) NULL,
    [RecordStatus] [char] (1) NOT NULL,         -- record status - used to determine if the record is active or not
    [RecordCreated] [datetime2] (0) NOT NULL    -- audit timestamp storing the date and time the record was created (is additional detail necessary?)
) ON [TABLES]
GO


-- clustered index on DatabaseTableID
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'[Monitor].[DatabaseTableColumns]') AND name = N'PK_DatabaseTableColumns')
ALTER TABLE [Monitor].[DatabaseTableColumns]
ADD  CONSTRAINT [PK_DatabaseTableColumns] PRIMARY KEY CLUSTERED ([DatabaseTableColumnID] ASC)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON, IGNORE_DUP_KEY = OFF, ONLINE = OFF, 
    ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [TABLES]
GO


-- default constraint on RecordStatus = "A"
ALTER TABLE [Monitor].[DatabaseTableColumns] ADD CONSTRAINT
	DF_DatabaseTableColumns_RecordStatus DEFAULT 'A' FOR RecordStatus
GO
-- check constraint on RecordStatus - allowed values "A", "D", "H"
ALTER TABLE [Monitor].[DatabaseTableColumns] ADD CONSTRAINT
	CK_DatabaseTableColumns_RecordStatus CHECK (RecordStatus LIKE '[ADH]')
GO

-- default constraint on RecordCreated = CURRENT_TIMESTAMP
ALTER TABLE [Monitor].[DatabaseTableColumns] ADD CONSTRAINT
	DF_DatabaseTableColumns_RecordCreated DEFAULT CURRENT_TIMESTAMP FOR RecordCreated
GO


USE [master]
GO
