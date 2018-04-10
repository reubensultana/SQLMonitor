USE [SQLMonitorArchive]
GO

IF OBJECT_ID('[Archive].[ServerEndpoints]') IS NOT NULL
BEGIN
    DROP TABLE [Archive].[ServerEndpoints];
END
GO

CREATE TABLE [Archive].[ServerEndpoints](
    [ServerEndpointID] [int] NOT NULL,
	[ServerName] [nvarchar](128) NOT NULL,
    [EndpointName] [nvarchar](128) NOT NULL,
    [Owner] [nvarchar](128) NOT NULL,
    [ProtocolDesc] [nvarchar](60) NOT NULL,
    [PayloadType] [nvarchar](60) NOT NULL,
    [StateDesc] [nvarchar](60) NOT NULL,
    [IsAdminEndpoint] [bit] NOT NULL,
    [RecordStatus] [char] (1) NOT NULL,         -- record status - used to determine if the record is active or not
    [RecordCreated] [datetime2] (0) NOT NULL    -- audit timestamp storing the date and time the record was created (is additional detail necessary?)
) ON [TABLES]
GO


-- clustered index on ServerInfoID
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'[Archive].[ServerEndpoints]') AND name = N'PK_ServerEndpoints_Archive')
ALTER TABLE [Archive].[ServerEndpoints]
ADD  CONSTRAINT [PK_ServerEndpoints_Archive] PRIMARY KEY CLUSTERED ([ServerEndpointID] ASC)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON, IGNORE_DUP_KEY = OFF, ONLINE = OFF, 
    ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [TABLES]
GO


USE [master]
GO
