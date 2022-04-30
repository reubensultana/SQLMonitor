IF OBJECT_ID('[Monitor].[ServerLogins]') IS NOT NULL
DROP TABLE [Monitor].[ServerLogins];
GO

CREATE TABLE [Monitor].[ServerLogins](
    [ServerLoginID] [int] IDENTITY(-2147483648,1) NOT NULL,
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
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'[Monitor].[ServerLogins]') AND name = N'PK_ServerLogins')
ALTER TABLE [Monitor].[ServerLogins]
ADD  CONSTRAINT [PK_ServerLogins] PRIMARY KEY CLUSTERED ([ServerLoginID] ASC)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON, IGNORE_DUP_KEY = OFF, ONLINE = OFF, 
    ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100)
GO


-- default constraint on RecordStatus = "A"
ALTER TABLE [Monitor].[ServerLogins] ADD CONSTRAINT
	DF_ServerLogins_RecordStatus DEFAULT 'A' FOR RecordStatus
GO
-- check constraint on RecordStatus - allowed values "A", "D", "H"
ALTER TABLE [Monitor].[ServerLogins] ADD CONSTRAINT
	CK_ServerLogins_RecordStatus CHECK (RecordStatus LIKE '[ADH]')
GO

-- default constraint on RecordCreated = SYSDATETIMEOFFSET()
ALTER TABLE [Monitor].[ServerLogins] ADD CONSTRAINT
	DF_ServerLogins_RecordCreated DEFAULT SYSDATETIMEOFFSET() FOR RecordCreated
GO
