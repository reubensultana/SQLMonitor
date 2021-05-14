USE [SQLMonitor]
GO

IF OBJECT_ID('[Staging].[DatabaseBackupHistory]') IS NOT NULL
BEGIN
    DROP TABLE [Staging].[DatabaseBackupHistory];
END
GO

CREATE TABLE [Staging].[DatabaseBackupHistory](
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


-- default constraint on RecordStatus = "A"
ALTER TABLE [Staging].[DatabaseBackupHistory] ADD CONSTRAINT
	DF_DatabaseBackupHistory_RecordStatus DEFAULT 'A' FOR RecordStatus
GO

-- default constraint on RecordCreated = SYSDATETIMEOFFSET()
ALTER TABLE [Staging].[DatabaseBackupHistory] ADD CONSTRAINT
	DF_DatabaseBackupHistory_RecordCreated DEFAULT SYSDATETIMEOFFSET() FOR RecordCreated
GO


USE [master]
GO
