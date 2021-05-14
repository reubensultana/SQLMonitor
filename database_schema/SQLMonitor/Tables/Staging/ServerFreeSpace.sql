USE [SQLMonitor]
GO

IF OBJECT_ID('[Staging].[ServerFreeSpace]') IS NOT NULL
BEGIN
    DROP TABLE [Staging].[ServerFreeSpace];
END
GO

CREATE TABLE [Staging].[ServerFreeSpace](
	[ServerName] [nvarchar](128) NOT NULL,
    [Drive] [char](1) NOT NULL,
    [FreeMB] [int] NOT NULL,
    [RecordStatus] [char] (1) NOT NULL,         -- record status - used to determine if the record is active or not
    [RecordCreated] [datetimeoffset] (7) NOT NULL    -- audit timestamp storing the date and time the record was created (is additional detail necessary?)
) ON [TABLES]
GO


-- default constraint on RecordStatus = "A"
ALTER TABLE [Staging].[ServerFreeSpace] ADD CONSTRAINT
	DF_ServerFreeSpace_RecordStatus DEFAULT 'A' FOR RecordStatus
GO

-- default constraint on RecordCreated = SYSDATETIMEOFFSET()
ALTER TABLE [Staging].[ServerFreeSpace] ADD CONSTRAINT
	DF_ServerFreeSpace_RecordCreated DEFAULT SYSDATETIMEOFFSET() FOR RecordCreated
GO


USE [master]
GO
