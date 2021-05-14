USE [SQLMonitor]
GO

IF OBJECT_ID('[Staging].[ServerAgentConfig]') IS NOT NULL
BEGIN
    DROP TABLE [Staging].[ServerAgentConfig];
END
GO

CREATE TABLE [Staging].[ServerAgentConfig](
	[ServerName] [nvarchar](128) NOT NULL,
    [AutoStart] [int] NOT NULL,
    [StartupAccount] [nvarchar] (128) NOT NULL,
    [JobHistoryMaxRows] [int] NOT NULL,
    [JobHistoryMaxRowsPerJob] [int] NOT NULL,
    [ErrorLogFile] [nvarchar] (255) NOT NULL,
    [EmailProfile] [nvarchar] (64) NULL,
    [FailSafeOperator] [nvarchar] (255) NULL,
    [RecordStatus] [char] (1) NOT NULL,        -- record status - used to determine if the record is active or not
    [RecordCreated] [datetimeoffset] (7) NOT NULL   -- audit timestamp storing the date and time the record was created (is additional detail necessary?)
) ON [TABLES]
GO


-- default constraint on RecordStatus = "A"
ALTER TABLE [Staging].[ServerAgentConfig] ADD CONSTRAINT
	DF_ServerAgentConfig_RecordStatus DEFAULT 'A' FOR RecordStatus
GO

-- default constraint on RecordCreated = SYSDATETIMEOFFSET()
ALTER TABLE [Staging].[ServerAgentConfig] ADD CONSTRAINT
	DF_ServerAgentConfig_RecordCreated DEFAULT SYSDATETIMEOFFSET() FOR RecordCreated
GO


USE [master]
GO
