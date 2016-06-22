USE [SQLMonitor]
GO

IF OBJECT_ID('[Monitor].[DatabaseUsers]') IS NOT NULL
BEGIN
    DROP TABLE [Monitor].[DatabaseUsers];
END
GO

CREATE TABLE [Monitor].[DatabaseUsers](
    [DatabaseUserID] [int] IDENTITY(-2147483648,1) NOT NULL,
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
    [RecordCreated] [datetime2] (0) NOT NULL   -- audit timestamp storing the date and time the record was created (is additional detail necessary?)
) ON [TABLES] TEXTIMAGE_ON [TABLES]
GO


-- clustered index on ServerInfoID
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'[Monitor].[DatabaseUsers]') AND name = N'PK_DatabaseUsers')
ALTER TABLE [Monitor].[DatabaseUsers]
ADD  CONSTRAINT [PK_DatabaseUsers] PRIMARY KEY CLUSTERED ([DatabaseUserID] ASC)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON, IGNORE_DUP_KEY = OFF, ONLINE = OFF, 
    ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [TABLES]
GO


-- default constraint on RecordStatus = "A"
ALTER TABLE [Monitor].[DatabaseUsers] ADD CONSTRAINT
	DF_DatabaseUsers_RecordStatus DEFAULT 'A' FOR RecordStatus
GO
-- check constraint on RecordStatus - allowed values "A", "D", "H"
ALTER TABLE [Monitor].[DatabaseUsers] ADD CONSTRAINT
	CK_DatabaseUsers_RecordStatus CHECK (RecordStatus LIKE '[ADH]')
GO

-- default constraint on RecordCreated = CURRENT_TIMESTAMP
ALTER TABLE [Monitor].[DatabaseUsers] ADD CONSTRAINT
	DF_DatabaseUsers_RecordCreated DEFAULT CURRENT_TIMESTAMP FOR RecordCreated
GO


USE [master]
GO
