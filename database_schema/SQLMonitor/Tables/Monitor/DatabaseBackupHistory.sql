USE [SQLMonitor]
GO

IF OBJECT_ID('[Monitor].[DatabaseBackupHistory]') IS NOT NULL
BEGIN
    DROP TABLE [Monitor].[DatabaseBackupHistory];
END
GO

CREATE TABLE [Monitor].[DatabaseBackupHistory](
    [DatabaseBackupHistoryID] [int] IDENTITY(-2147483648,1) NOT NULL,
	[ServerName] [nvarchar](128) NOT NULL,
    [DatabaseName] [nvarchar](128) NOT NULL,
    [BackupType] [varchar](25) NULL,
    [BackupName] [nvarchar](128) NULL,
    [LoginName] [nvarchar](128) NULL,
    [StartDate] [datetime] NULL,
    [FinishDate] [datetime] NULL,
    [BackupSizeMB] [decimal](20,2) NULL,
    [SourceServer] [nvarchar](128) NULL,
    [PhysicalDeviceName] [nvarchar](260) NULL,
    [LogicalDeviceName] [nvarchar](128) NULL,
    [ExpirationDate] [datetime] NULL,
    [Description] [nvarchar](255) NULL,
    [RecordStatus] [char] (1) NOT NULL,         -- record status - used to determine if the record is active or not
    [RecordCreated] [datetimeoffset] (7) NOT NULL    -- audit timestamp storing the date and time the record was created (is additional detail necessary?)
) ON [TABLES]
GO


-- clustered index on DatabaseTableID
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'[Monitor].[DatabaseBackupHistory]') AND name = N'PK_DatabaseBackupHistory')
ALTER TABLE [Monitor].[DatabaseBackupHistory]
ADD  CONSTRAINT [PK_DatabaseBackupHistory] PRIMARY KEY CLUSTERED ([DatabaseBackupHistoryID] ASC)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON, IGNORE_DUP_KEY = OFF, ONLINE = OFF, 
    ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [TABLES]
GO

-- indexes created for performance
CREATE NONCLUSTERED INDEX [IX_DatabaseBackupHistory_ServerName]
ON [Monitor].[DatabaseBackupHistory] ([ServerName])
INCLUDE ([StartDate])
WITH (
    PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON, IGNORE_DUP_KEY = OFF, 
    DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90
)
GO

-- default constraint on RecordStatus = "A"
ALTER TABLE [Monitor].[DatabaseBackupHistory] ADD CONSTRAINT
	DF_DatabaseBackupHistory_RecordStatus DEFAULT 'A' FOR RecordStatus
GO
-- check constraint on RecordStatus - allowed values "A", "D", "H"
ALTER TABLE [Monitor].[DatabaseBackupHistory] ADD CONSTRAINT
	CK_DatabaseBackupHistory_RecordStatus CHECK (RecordStatus LIKE '[ADH]')
GO

-- default constraint on RecordCreated = SYSDATETIMEOFFSET()
ALTER TABLE [Monitor].[DatabaseBackupHistory] ADD CONSTRAINT
	DF_DatabaseBackupHistory_RecordCreated DEFAULT SYSDATETIMEOFFSET() FOR RecordCreated
GO


USE [master]
GO
