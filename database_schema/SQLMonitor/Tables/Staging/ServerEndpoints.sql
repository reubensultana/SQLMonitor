USE [SQLMonitor]
GO

IF OBJECT_ID('[Staging].[ServerEndpoints]') IS NOT NULL
BEGIN
    DROP TABLE [Staging].[ServerEndpoints];
END
GO

CREATE TABLE [Staging].[ServerEndpoints](
	[ServerName] [nvarchar](128) NOT NULL,
    [EndpointName] [nvarchar](128) NOT NULL,
    [Owner] [nvarchar](128) NOT NULL,
    [ProtocolDesc] [nvarchar](60) NOT NULL,
    [PayloadType] [nvarchar](60) NOT NULL,
    [StateDesc] [nvarchar](60) NOT NULL,
    [IsAdminEndpoint] [bit] NOT NULL,
    [RecordStatus] [char] (1) NOT NULL,         -- record status - used to determine if the record is active or not
    [RecordCreated] [datetimeoffset] (7) NOT NULL    -- audit timestamp storing the date and time the record was created (is additional detail necessary?)
) ON [TABLES]
GO


-- default constraint on RecordStatus = "A"
ALTER TABLE [Staging].[ServerEndpoints] ADD CONSTRAINT
	DF_ServerEndpoints_RecordStatus DEFAULT 'A' FOR RecordStatus
GO

-- default constraint on RecordCreated = SYSDATETIMEOFFSET()
ALTER TABLE [Staging].[ServerEndpoints] ADD CONSTRAINT
	DF_ServerEndpoints_RecordCreated DEFAULT SYSDATETIMEOFFSET() FOR RecordCreated
GO


USE [master]
GO
