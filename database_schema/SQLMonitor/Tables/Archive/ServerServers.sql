USE [SQLMonitor]
GO

IF OBJECT_ID('[Archive].[ServerServers]') IS NOT NULL
BEGIN
    DROP TABLE [Archive].[ServerServers];
END
GO

CREATE TABLE [Archive].[ServerServers](
    [ServerServerID] [int] NOT NULL,
	[ServerName] [nvarchar](128) NOT NULL,
    [ServerID] [int] NOT NULL,
    [LinkedServer] [nvarchar](128) NOT NULL,
    [ProductName] [nvarchar](128) NOT NULL,
    [ProviderName] [nvarchar](128) NOT NULL,
    [DataSource] [nvarchar](400) NULL,
    [ProviderString] [nvarchar](400) NULL,
    [CatalogConnection] [nvarchar](128) NULL,
    [RecordStatus] [char] (1) NOT NULL,         -- record status - used to determine if the record is active or not
    [RecordCreated] [datetime2] (0) NOT NULL    -- audit timestamp storing the date and time the record was created (is additional detail necessary?)
) ON [ARCHIVE]
GO


-- clustered index on ServerInfoID
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'[Archive].[ServerServers]') AND name = N'PK_ServerServers_Archive')
ALTER TABLE [Archive].[ServerServers]
ADD  CONSTRAINT [PK_ServerServers_Archive] PRIMARY KEY CLUSTERED ([ServerServerID] ASC)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON, IGNORE_DUP_KEY = OFF, ONLINE = OFF, 
    ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [ARCHIVE]
GO


USE [master]
GO
