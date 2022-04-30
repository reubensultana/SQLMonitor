IF OBJECT_ID('[Archive].[ServerLogins]') IS NOT NULL
DROP TABLE [Archive].[ServerLogins];
GO

CREATE TABLE [Archive].[ServerLogins](
    [ServerLoginID] [int] NOT NULL,
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
)
GO


-- clustered index on ServerInfoID
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'[Archive].[ServerLogins]') AND name = N'PK_ServerLogins_Archive')
ALTER TABLE [Archive].[ServerLogins]
ADD  CONSTRAINT [PK_ServerLogins_Archive] PRIMARY KEY CLUSTERED ([ServerLoginID] ASC)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON, IGNORE_DUP_KEY = OFF, ONLINE = OFF, 
    ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100)
GO
