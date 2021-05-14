USE [SQLMonitor]
GO

IF OBJECT_ID('[Staging].[DatabaseUsers]') IS NOT NULL
BEGIN
    DROP TABLE [Staging].[DatabaseUsers];
END
GO

CREATE TABLE [Staging].[DatabaseUsers](
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


-- default constraint on RecordStatus = "A"
ALTER TABLE [Staging].[DatabaseUsers] ADD CONSTRAINT
	DF_DatabaseUsers_RecordStatus DEFAULT 'A' FOR RecordStatus
GO

-- default constraint on RecordCreated = SYSDATETIMEOFFSET()
ALTER TABLE [Staging].[DatabaseUsers] ADD CONSTRAINT
	DF_DatabaseUsers_RecordCreated DEFAULT SYSDATETIMEOFFSET() FOR RecordCreated
GO


USE [master]
GO
