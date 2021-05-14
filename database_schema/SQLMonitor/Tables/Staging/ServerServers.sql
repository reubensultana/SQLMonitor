USE [SQLMonitor]
GO

IF OBJECT_ID('[Staging].[ServerServers]') IS NOT NULL
BEGIN
    DROP TABLE [Staging].[ServerServers];
END
GO

CREATE TABLE [Staging].[ServerServers](
	[ServerName] [nvarchar](128) NOT NULL,
    [ServerID] [int] NOT NULL,
    [LinkedServer] [nvarchar](128) NOT NULL,
    [ProductName] [nvarchar](128) NOT NULL,
    [ProviderName] [nvarchar](128) NOT NULL,
    [DataSource] [nvarchar](400) NULL,
    [ProviderString] [nvarchar](400) NULL,
    [CatalogConnection] [nvarchar](128) NULL,
    [RecordStatus] [char] (1) NOT NULL,         -- record status - used to determine if the record is active or not
    [RecordCreated] [datetimeoffset] (7) NOT NULL    -- audit timestamp storing the date and time the record was created (is additional detail necessary?)
) ON [TABLES]
GO


-- default constraint on RecordStatus = "A"
ALTER TABLE [Staging].[ServerServers] ADD CONSTRAINT
	DF_ServerServers_RecordStatus DEFAULT 'A' FOR RecordStatus
GO

-- default constraint on RecordCreated = SYSDATETIMEOFFSET()
ALTER TABLE [Staging].[ServerServers] ADD CONSTRAINT
	DF_ServerServers_RecordCreated DEFAULT SYSDATETIMEOFFSET() FOR RecordCreated
GO


USE [master]
GO
