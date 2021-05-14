USE [SQLMonitor]
GO

IF OBJECT_ID('[Staging].[DatabaseConfigurations]') IS NOT NULL
BEGIN
    DROP TABLE [Staging].[DatabaseConfigurations];
END
GO

CREATE TABLE [Staging].[DatabaseConfigurations](
	[ServerName] [nvarchar](128) NOT NULL,
    [DatabaseName] [nvarchar](128) NOT NULL,
    [FileID] [int] NOT NULL,
    [FileType] [nvarchar](60) NOT NULL,
    [FileName] [nvarchar](128) NOT NULL,
    [FilePath] [nvarchar](260) NOT NULL,
    [State] [nvarchar](60) NOT NULL,
    [IsReadOnly] [bit] NOT NULL,
    [SizeMB] [numeric](15,2) NOT NULL,
    [MaxSizeMB] [numeric](15,0) NOT NULL,
    [GrowthMB] [numeric](15,0) NOT NULL,
    [IsPercentGrowth] [bit] NOT NULL,
    [RecordStatus] [char] (1) NOT NULL,        -- record status - used to determine if the record is active or not
    [RecordCreated] [datetimeoffset] (7) NOT NULL   -- audit timestamp storing the date and time the record was created (is additional detail necessary?)
) ON [TABLES]
GO


-- default constraint on RecordStatus = "A"
ALTER TABLE [Staging].[DatabaseConfigurations] ADD CONSTRAINT
	DF_DatabaseConfigurations_RecordStatus DEFAULT 'A' FOR RecordStatus
GO

-- default constraint on RecordCreated = SYSDATETIMEOFFSET()
ALTER TABLE [Staging].[DatabaseConfigurations] ADD CONSTRAINT
	DF_DatabaseConfigurations_RecordCreated DEFAULT SYSDATETIMEOFFSET() FOR RecordCreated
GO


USE [master]
GO
