USE [SQLMonitor]
GO

IF OBJECT_ID('[Monitor].[ServerFreeSpace]') IS NOT NULL
BEGIN
    DROP TABLE [Monitor].[ServerFreeSpace];
END
GO

CREATE TABLE [Monitor].[ServerFreeSpace](
    [ServerFreeSpaceID] [int] IDENTITY(-2147483648,1) NOT NULL,
	[ServerName] [nvarchar](128) NOT NULL,
    [Drive] [char](1) NOT NULL,
    [FreeMB] [int] NOT NULL,
    [RecordStatus] [char] (1) NOT NULL,         -- record status - used to determine if the record is active or not
    [RecordCreated] [datetime2] (0) NOT NULL    -- audit timestamp storing the date and time the record was created (is additional detail necessary?)
) ON [TABLES]
GO


-- clustered index on ServerInfoID
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'[Monitor].[ServerFreeSpace]') AND name = N'PK_ServerFreeSpace')
ALTER TABLE [Monitor].[ServerFreeSpace]
ADD  CONSTRAINT [PK_ServerFreeSpace] PRIMARY KEY CLUSTERED ([ServerFreeSpaceID] ASC)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON, IGNORE_DUP_KEY = OFF, ONLINE = OFF, 
    ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [TABLES]
GO


-- default constraint on RecordStatus = "A"
ALTER TABLE [Monitor].[ServerFreeSpace] ADD CONSTRAINT
	DF_ServerFreeSpace_RecordStatus DEFAULT 'A' FOR RecordStatus
GO
-- check constraint on RecordStatus - allowed values "A", "D", "H"
ALTER TABLE [Monitor].[ServerFreeSpace] ADD CONSTRAINT
	CK_ServerFreeSpace_RecordStatus CHECK (RecordStatus LIKE '[ADH]')
GO

-- default constraint on RecordCreated = CURRENT_TIMESTAMP
ALTER TABLE [Monitor].[ServerFreeSpace] ADD CONSTRAINT
	DF_ServerFreeSpace_RecordCreated DEFAULT CURRENT_TIMESTAMP FOR RecordCreated
GO


USE [master]
GO
