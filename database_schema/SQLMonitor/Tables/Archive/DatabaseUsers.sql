USE [SQLMonitorArchive]
GO

IF OBJECT_ID('[Archive].[DatabaseUsers]') IS NOT NULL
BEGIN
    DROP TABLE [Archive].[DatabaseUsers];
END
GO

CREATE TABLE [Archive].[DatabaseUsers](
    [DatabaseUserID] [int] NOT NULL,
	[ServerName] [nvarchar](128) NOT NULL,
	[DatabaseName] [nvarchar](128) NOT NULL,
    [PrincipalName] [nvarchar](128) NOT NULL,
	[db_accessadmin] [int] NOT NULL,
	[db_backupoperator] [int] NOT NULL,
	[db_ddladmin] [int] NOT NULL,
	[db_owner] [int] NOT NULL,
	[db_securityadmin] [int] NOT NULL,
	[SecurablesPermissions] [varchar](max) NOT NULL,
    [RecordStatus] [char] (1) NOT NULL,        -- record status - used to determine if the record is active or not
    [RecordCreated] [datetimeoffset] (7) NOT NULL   -- audit timestamp storing the date and time the record was created (is additional detail necessary?)
) ON [TABLES] TEXTIMAGE_ON [TABLES]
GO


-- clustered index on ServerInfoID
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'[Archive].[DatabaseUsers]') AND name = N'PK_DatabaseUsers_Archive')
ALTER TABLE [Archive].[DatabaseUsers]
ADD  CONSTRAINT [PK_DatabaseUsers_Archive] PRIMARY KEY CLUSTERED ([DatabaseUserID] ASC)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON, IGNORE_DUP_KEY = OFF, ONLINE = OFF, 
    ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [TABLES]
GO


USE [master]
GO
