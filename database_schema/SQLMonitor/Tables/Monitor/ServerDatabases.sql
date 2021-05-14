USE [SQLMonitor]
GO

IF OBJECT_ID('[Monitor].[ServerDatabases]') IS NOT NULL
BEGIN
    DROP TABLE [Monitor].[ServerDatabases];
END
GO

CREATE TABLE [Monitor].[ServerDatabases](
    [ServerDatabaseID] [int] IDENTITY(-2147483648,1) NOT NULL,
	[ServerName] [nvarchar](128) NOT NULL,
    [DatabaseName] [nvarchar](128) NOT NULL,
    [DatabaseOwner] [nvarchar](128) NOT NULL,
    [CreateDate] [datetime] NOT NULL,
    [CompatibilityLevel] [tinyint] NOT NULL,
    [CollationName] [nvarchar](128) NOT NULL,
    [UserAccess] [nvarchar](60) NOT NULL,
    [IsReadOnly] [bit] NOT NULL,
    [IsAutoClose] [bit] NOT NULL,
    [IsAutoShrink] [bit] NOT NULL,
    [State] [nvarchar](60) NOT NULL,
    [IsInStandby] [bit] NOT NULL,
    [RecoveryModel] [nvarchar](60) NOT NULL,
    [PageVerifyOption] [nvarchar](60) NOT NULL,
    [IsFullTextEnabled] [bit] NOT NULL,
    [IsTrustworthy] [bit] NOT NULL,
    [RecordStatus] [char] (1) NOT NULL,        -- record status - used to determine if the record is active or not
    [RecordCreated] [datetimeoffset] (7) NOT NULL   -- audit timestamp storing the date and time the record was created (is additional detail necessary?)
) ON [TABLES]
GO


-- clustered index on ServerDatabaseID
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'[Monitor].[ServerDatabases]') AND name = N'PK_ServerDatabases')
ALTER TABLE [Monitor].[ServerDatabases]
ADD  CONSTRAINT [PK_ServerDatabases] PRIMARY KEY CLUSTERED ([ServerDatabaseID] ASC)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON, IGNORE_DUP_KEY = OFF, ONLINE = OFF, 
    ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [TABLES]
GO


-- default constraint on RecordStatus = "A"
ALTER TABLE [Monitor].[ServerDatabases] ADD CONSTRAINT
	DF_ServerDatabases_RecordStatus DEFAULT 'A' FOR RecordStatus
GO
-- check constraint on RecordStatus - allowed values "A", "D", "H"
ALTER TABLE [Monitor].[ServerDatabases] ADD CONSTRAINT
	CK_ServerDatabases_RecordStatus CHECK (RecordStatus LIKE '[ADH]')
GO

-- default constraint on RecordCreated = SYSDATETIMEOFFSET()
ALTER TABLE [Monitor].[ServerDatabases] ADD CONSTRAINT
	DF_ServerDatabases_RecordCreated DEFAULT SYSDATETIMEOFFSET() FOR RecordCreated
GO


USE [master]
GO
