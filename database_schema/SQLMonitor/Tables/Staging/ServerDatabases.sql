USE [SQLMonitor]
GO

IF OBJECT_ID('[Staging].[ServerDatabases]') IS NOT NULL
BEGIN
    DROP TABLE [Staging].[ServerDatabases];
END
GO

CREATE TABLE [Staging].[ServerDatabases](
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


-- default constraint on RecordStatus = "A"
ALTER TABLE [Staging].[ServerDatabases] ADD CONSTRAINT
	DF_ServerDatabases_RecordStatus DEFAULT 'A' FOR RecordStatus
GO

-- default constraint on RecordCreated = SYSDATETIMEOFFSET()
ALTER TABLE [Staging].[ServerDatabases] ADD CONSTRAINT
	DF_ServerDatabases_RecordCreated DEFAULT SYSDATETIMEOFFSET() FOR RecordCreated
GO


USE [master]
GO
