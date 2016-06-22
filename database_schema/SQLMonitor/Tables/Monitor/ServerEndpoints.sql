USE [SQLMonitor]
GO

IF OBJECT_ID('[Monitor].[ServerEndpoints]') IS NOT NULL
BEGIN
    DROP TABLE [Monitor].[ServerEndpoints];
END
GO

CREATE TABLE [Monitor].[ServerEndpoints](
    [ServerEndpointID] [int] IDENTITY(-2147483648,1) NOT NULL,
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
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'[Monitor].[ServerEndpoints]') AND name = N'PK_ServerEndpoints')
ALTER TABLE [Monitor].[ServerEndpoints]
ADD  CONSTRAINT [PK_ServerEndpoints] PRIMARY KEY CLUSTERED ([ServerEndpointID] ASC)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON, IGNORE_DUP_KEY = OFF, ONLINE = OFF, 
    ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [TABLES]
GO


-- default constraint on RecordStatus = "A"
ALTER TABLE [Monitor].[ServerEndpoints] ADD CONSTRAINT
	DF_ServerEndpoints_RecordStatus DEFAULT 'A' FOR RecordStatus
GO
-- check constraint on RecordStatus - allowed values "A", "D", "H"
ALTER TABLE [Monitor].[ServerEndpoints] ADD CONSTRAINT
	CK_ServerEndpoints_RecordStatus CHECK (RecordStatus LIKE '[ADH]')
GO

-- default constraint on RecordCreated = CURRENT_TIMESTAMP
ALTER TABLE [Monitor].[ServerEndpoints] ADD CONSTRAINT
	DF_ServerEndpoints_RecordCreated DEFAULT CURRENT_TIMESTAMP FOR RecordCreated
GO


USE [master]
GO
