USE [SQLMonitor]
GO

IF OBJECT_ID('[Staging].[ServerInfo]') IS NOT NULL
BEGIN
    DROP TABLE [Staging].[ServerInfo];
END
GO

CREATE TABLE [Staging].[ServerInfo](
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
    [RecordCreated] [datetimeoffset] (7) NOT NULL    -- audit timestamp storing the date and time the record was created (is additional detail necessary?)
) ON [TABLES]
GO


-- default constraint on RecordStatus = "A"
ALTER TABLE [Staging].[ServerInfo] ADD CONSTRAINT
	DF_ServerInfo_RecordStatus DEFAULT 'A' FOR RecordStatus
GO

-- default constraint on RecordCreated = SYSDATETIMEOFFSET()
ALTER TABLE [Staging].[ServerInfo] ADD CONSTRAINT
	DF_ServerInfo_RecordCreated DEFAULT SYSDATETIMEOFFSET() FOR RecordCreated
GO


USE [master]
GO
