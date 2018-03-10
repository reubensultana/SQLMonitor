USE [SQLMonitor]
GO

IF OBJECT_ID('[dbo].[MonitoredServers]') IS NOT NULL
DROP TABLE [dbo].[MonitoredServers];
GO

CREATE TABLE [dbo].[MonitoredServers] (
    [ServerId]          [int] IDENTITY(1,1) NOT NULL,   -- unique identifier
    [ServerName]        [nvarchar] (128) NOT NULL,      -- server name
    [ServerAlias]       [nvarchar] (128) NULL,          -- server alias (for servers which have been set up incorrectly)
    [ServerDescription] [varchar] (500) NULL,           -- short description
    [ServerIpAddress]   [varchar] (20) NOT NULL,        -- server ip address
    [SqlTcpPort]        [int] NOT NULL,                 -- instance listening port used for data collection
    [ServerDomain]		[nvarchar] (15) NOT NULL,		-- the server domain name
	[ServerOrder]       [smallint] NOT NULL,            -- result set ordering - used to define a specific order how servers are processed
    [SqlVersion]        [numeric] (6, 2) NULL,          -- dbms version - may have to be used for version-specific scripts
    [RecordStatus]      [char] (1) NOT NULL,            -- record status - used to determine if server will be processed or not
    [RecordCreated]     [datetime2] (0) NOT NULL        -- audit timestamp storing the date and time the record was created (is additional detail necessary?)
) ON [TABLES]
GO


-- clustered index on ServerId
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[MonitoredServers]') AND name = N'PK_MonitoredServers')
ALTER TABLE [dbo].[MonitoredServers]
ADD  CONSTRAINT [PK_MonitoredServers] PRIMARY KEY CLUSTERED ([ServerId] ASC)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON, IGNORE_DUP_KEY = OFF, ONLINE = OFF, 
    ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [TABLES]
GO

-- unique constraint on ServerName AND TcpPort
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[MonitoredServers]') AND name = N'IX_MonitoredServers_ServerName')
CREATE UNIQUE NONCLUSTERED INDEX [IX_MonitoredServers_ServerName_TcpPort] 
ON [dbo].[MonitoredServers] ([ServerName] ASC, [SqlTcpPort] ASC)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON, DROP_EXISTING = OFF, ONLINE = OFF, 
    ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [TABLES]
GO

-- unique constraint on ServerIpAddress AND TcpPort
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[MonitoredServers]') AND name = N'IX_MonitoredServers_ServerIpAddress')
CREATE UNIQUE NONCLUSTERED INDEX [IX_MonitoredServers_ServerIpAddress_TcpPort] 
ON [dbo].[MonitoredServers] ([ServerIpAddress] ASC, [SqlTcpPort] ASC)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON, DROP_EXISTING = OFF, ONLINE = OFF, 
    ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [TABLES]
GO

-- default constraint on ServerOrder = "0"
ALTER TABLE dbo.MonitoredServers ADD CONSTRAINT
	DF_MonitoredServers_ServerOrder DEFAULT 0 FOR ServerOrder
GO

-- default constraint on RecordStatus = "A"
ALTER TABLE dbo.MonitoredServers ADD CONSTRAINT
	DF_MonitoredServers_RecordStatus DEFAULT 'A' FOR RecordStatus
GO
-- check constraint on RecordStatus - allowed values "A", "D", "H"
ALTER TABLE dbo.MonitoredServers ADD CONSTRAINT
	CK_MonitoredServers_RecordStatus CHECK (RecordStatus LIKE '[ADH]')
GO

-- default constraint on RecordCreated = CURRENT_TIMESTAMP
ALTER TABLE dbo.MonitoredServers ADD CONSTRAINT
	DF_MonitoredServers_RecordCreated DEFAULT CURRENT_TIMESTAMP FOR RecordCreated
GO

-- TODO: create trigger firing when RecordStatus is set to "D"


USE [master]
GO
