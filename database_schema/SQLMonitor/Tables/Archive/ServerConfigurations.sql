USE [SQLMonitorArchive]
GO

IF OBJECT_ID('[Archive].[ServerConfigurations]') IS NOT NULL
BEGIN
    DROP TABLE [Archive].[ServerConfigurations];
END
GO

CREATE TABLE [Archive].[ServerConfigurations](
    [ServerConfigID] [int] NOT NULL,
	[ServerName] [nvarchar](128) NOT NULL,
    [ConfigID] [int] NOT NULL,
    [ConfigName] [nvarchar](255) NOT NULL,
    [ValueSet] [int] NOT NULL,
    [ValueInUse] [int] NOT NULL,
    [RecordStatus] [char] (1) NOT NULL,        -- record status - used to determine if the record is active or not
    [RecordCreated] [datetime2] (0) NOT NULL   -- audit timestamp storing the date and time the record was created (is additional detail necessary?)
) ON [TABLES]
GO


-- clustered index on ServerInfoID
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'[Archive].[ServerConfigurations]') AND name = N'PK_ServerConfigurations_Archive')
ALTER TABLE [Archive].[ServerConfigurations]
ADD  CONSTRAINT [PK_ServerConfigurations_Archive] PRIMARY KEY CLUSTERED ([ServerConfigID] ASC)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON, IGNORE_DUP_KEY = OFF, ONLINE = OFF, 
    ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [TABLES]
GO


USE [master]
GO
