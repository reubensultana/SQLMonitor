USE [SQLMonitorArchive]
GO

IF OBJECT_ID('[Archive].[ServerDatabases]') IS NOT NULL
BEGIN
    DROP TABLE [Archive].[ServerDatabases];
END
GO

CREATE TABLE [Archive].[ServerDatabases](
    [ServerDatabaseID] [int] NOT NULL,
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
    [RecordCreated] [datetime2] (0) NOT NULL   -- audit timestamp storing the date and time the record was created (is additional detail necessary?)
) ON [TABLES]
GO


-- clustered index on ServerDatabaseID
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'[Archive].[ServerDatabases]') AND name = N'PK_ServerDatabases_Archive')
ALTER TABLE [Archive].[ServerDatabases]
ADD  CONSTRAINT [PK_ServerDatabases_Archive] PRIMARY KEY CLUSTERED ([ServerDatabaseID] ASC)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON, IGNORE_DUP_KEY = OFF, ONLINE = OFF, 
    ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [TABLES]
GO


USE [master]
GO
