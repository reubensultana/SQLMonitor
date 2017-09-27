USE [SQLMonitor]
GO

IF OBJECT_ID('[Archive].[ServerInfo]') IS NOT NULL
BEGIN
    DROP TABLE [Archive].[ServerInfo];
END
GO

CREATE TABLE [Archive].[ServerInfo](
    [ServerInfoID] [int] NOT NULL,
	[ServerName] [nvarchar](128) NOT NULL,
	[ProductVersion] [nvarchar](128) NOT NULL,
	[ProductLevel] [nvarchar](128) NOT NULL,
	[ResourceLastUpdateDateTime] [datetime] NOT NULL,
	[ResourceVersion] [nvarchar](128) NOT NULL,
	[ServerAuthentication] [varchar](22) NOT NULL,
	[Edition] [nvarchar](128) NOT NULL,
	[InstanceName] [nvarchar](128) NOT NULL,
	[ComputerNamePhysicalNetBIOS] [nvarchar](128) NOT NULL,
	[BuildClrVersion] [nvarchar](128) NOT NULL,
	[Collation] [nvarchar](128) NOT NULL,
	[IsClustered] [bit] NOT NULL,
	[IsFullTextInstalled] [bit] NOT NULL,
	[SqlCharSetName] [nvarchar](128) NOT NULL,
	[SqlSortOrderName] [nvarchar](128) NOT NULL,
	[SqlRootPath] nvarchar(512) NOT NULL,
	[Product] nvarchar(128) NOT NULL,
	[Language] nvarchar(128) NOT NULL,
	[Platform] nvarchar(128) NOT NULL,
	[LogicalProcessors] [int] NOT NULL,
	[OSVersion] nvarchar(128) NOT NULL,
	[TotalMemoryMB] [int] NOT NULL,
    [RecordStatus] [char] (1) NOT NULL,         -- record status - used to determine if the record is active or not
    [RecordCreated] [datetime2] (0) NOT NULL    -- audit timestamp storing the date and time the record was created (is additional detail necessary?)
) ON [ARCHIVE]
GO


-- clustered index on ServerInfoID
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'[Archive].[ServerInfo]') AND name = N'PK_ServerInfo_Archive')
ALTER TABLE [Archive].[ServerInfo]
ADD  CONSTRAINT [PK_ServerInfo_Archive] PRIMARY KEY CLUSTERED ([ServerInfoID] ASC)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON, IGNORE_DUP_KEY = OFF, ONLINE = OFF, 
    ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [ARCHIVE]
GO


USE [master]
GO
