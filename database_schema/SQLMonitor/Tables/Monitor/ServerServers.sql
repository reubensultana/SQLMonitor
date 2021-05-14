USE [SQLMonitor]
GO

IF OBJECT_ID('[Monitor].[ServerServers]') IS NOT NULL
BEGIN
    DROP TABLE [Monitor].[ServerServers];
END
GO

CREATE TABLE [Monitor].[ServerServers](
    [ServerServerID] [int] IDENTITY(-2147483648,1) NOT NULL,
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


-- clustered index on ServerInfoID
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'[Monitor].[ServerServers]') AND name = N'PK_ServerServers')
ALTER TABLE [Monitor].[ServerServers]
ADD  CONSTRAINT [PK_ServerServers] PRIMARY KEY CLUSTERED ([ServerServerID] ASC)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON, IGNORE_DUP_KEY = OFF, ONLINE = OFF, 
    ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [TABLES]
GO


-- default constraint on RecordStatus = "A"
ALTER TABLE [Monitor].[ServerServers] ADD CONSTRAINT
	DF_ServerServers_RecordStatus DEFAULT 'A' FOR RecordStatus
GO
-- check constraint on RecordStatus - allowed values "A", "D", "H"
ALTER TABLE [Monitor].[ServerServers] ADD CONSTRAINT
	CK_ServerServers_RecordStatus CHECK (RecordStatus LIKE '[ADH]')
GO

-- default constraint on RecordCreated = SYSDATETIMEOFFSET()
ALTER TABLE [Monitor].[ServerServers] ADD CONSTRAINT
	DF_ServerServers_RecordCreated DEFAULT SYSDATETIMEOFFSET() FOR RecordCreated
GO


USE [master]
GO
