IF OBJECT_ID('[Monitor].[ServerFreeSpace]') IS NOT NULL
DROP TABLE [Monitor].[ServerFreeSpace];
GO

CREATE TABLE [Monitor].[ServerFreeSpace](
    [ServerFreeSpaceID] [int] IDENTITY(-2147483648,1) NOT NULL,
	[ServerName] [nvarchar](128) NOT NULL,
    [Drive] [char](1) NOT NULL,
    [FreeMB] [int] NOT NULL,
    [RecordStatus] [char] (1) NOT NULL,         -- record status - used to determine if the record is active or not
    [RecordCreated] [datetimeoffset] (7) NOT NULL    -- audit timestamp storing the date and time the record was created (is additional detail necessary?)
)
GO


-- clustered index on ServerInfoID
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'[Monitor].[ServerFreeSpace]') AND name = N'PK_ServerFreeSpace')
ALTER TABLE [Monitor].[ServerFreeSpace]
ADD  CONSTRAINT [PK_ServerFreeSpace] PRIMARY KEY CLUSTERED ([ServerFreeSpaceID] ASC)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON, IGNORE_DUP_KEY = OFF, ONLINE = OFF, 
    ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100)
GO


-- default constraint on RecordStatus = "A"
ALTER TABLE [Monitor].[ServerFreeSpace] ADD CONSTRAINT
	DF_ServerFreeSpace_RecordStatus DEFAULT 'A' FOR RecordStatus
GO
-- check constraint on RecordStatus - allowed values "A", "D", "H"
ALTER TABLE [Monitor].[ServerFreeSpace] ADD CONSTRAINT
	CK_ServerFreeSpace_RecordStatus CHECK (RecordStatus LIKE '[ADH]')
GO

-- default constraint on RecordCreated = SYSDATETIMEOFFSET()
ALTER TABLE [Monitor].[ServerFreeSpace] ADD CONSTRAINT
	DF_ServerFreeSpace_RecordCreated DEFAULT SYSDATETIMEOFFSET() FOR RecordCreated
GO
