USE [SQLMonitorArchive]
GO

IF OBJECT_ID('[Archive].[DatabaseBackupHistory]') IS NOT NULL
BEGIN
    DROP TABLE [Archive].[DatabaseBackupHistory];
END
GO

CREATE TABLE [Archive].[DatabaseBackupHistory](
    [DatabaseBackupHistoryID] [int] NOT NULL,
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
    [RecordCreated] [datetime2] (0) NOT NULL    -- audit timestamp storing the date and time the record was created (is additional detail necessary?)
) ON [TABLES]
GO


-- clustered index on DatabaseTableID
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'[Archive].[DatabaseBackupHistory]') AND name = N'PK_DatabaseBackupHistory_Archive')
ALTER TABLE [Archive].[DatabaseBackupHistory]
ADD  CONSTRAINT [PK_DatabaseBackupHistory_Archive] PRIMARY KEY CLUSTERED ([DatabaseBackupHistoryID] ASC)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON, IGNORE_DUP_KEY = OFF, ONLINE = OFF, 
    ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [TABLES]
GO


USE [master]
GO
