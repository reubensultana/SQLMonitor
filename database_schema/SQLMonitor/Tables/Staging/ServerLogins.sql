USE [SQLMonitor]
GO

IF OBJECT_ID('[Staging].[ServerLogins]') IS NOT NULL
BEGIN
    DROP TABLE [Staging].[ServerLogins];
END
GO

CREATE TABLE [Staging].[ServerLogins](
	[ServerName] [nvarchar](128) NOT NULL,
	[LoginName] [nvarchar](128) NOT NULL,
	[Type] [nvarchar](60) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
	[ModifyDate] [datetime] NOT NULL,
	[PasswordLastSet] [datetime] NULL,
	[DefaultDatabase] [nvarchar](128) NOT NULL,
	[DefaultLanguage] [nvarchar](128) NOT NULL,
	[IsDisabled] [bit] NOT NULL,
	[IsPolicyChecked] [int] NOT NULL,
	[IsExpirationChecked] [int] NOT NULL,
	[sysadmin] [int] NOT NULL,
	[securityadmin] [int] NOT NULL,
	[serveradmin] [int] NOT NULL,
	[setupadmin] [int] NOT NULL,
	[processadmin] [int] NOT NULL,
	[diskadmin] [int] NOT NULL,
	[dbcreator] [int] NOT NULL,
	[bulkadmin] [int] NOT NULL,
	[SecurablesPermissions] [varchar](max) NOT NULL,
    [RecordStatus] [char] (1) NOT NULL,        -- record status - used to determine if the record is active or not
    [RecordCreated] [datetimeoffset] (7) NOT NULL   -- audit timestamp storing the date and time the record was created (is additional detail necessary?)
) ON [TABLES] TEXTIMAGE_ON [TABLES]
GO


-- default constraint on RecordStatus = "A"
ALTER TABLE [Staging].[ServerLogins] ADD CONSTRAINT
	DF_ServerLogins_RecordStatus DEFAULT 'A' FOR RecordStatus
GO

-- default constraint on RecordCreated = SYSDATETIMEOFFSET()
ALTER TABLE [Staging].[ServerLogins] ADD CONSTRAINT
	DF_ServerLogins_RecordCreated DEFAULT SYSDATETIMEOFFSET() FOR RecordCreated
GO


USE [master]
GO
