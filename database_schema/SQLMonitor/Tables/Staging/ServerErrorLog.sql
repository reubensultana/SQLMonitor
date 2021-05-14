USE [SQLMonitor]
GO

IF OBJECT_ID('[Staging].[ServerErrorLog]') IS NOT NULL
BEGIN
    DROP TABLE [Staging].[ServerErrorLog];
END
GO

CREATE TABLE [Staging].[ServerErrorLog](
	[ServerName] [nvarchar](128) NOT NULL,
	[LogDate] [datetime] NOT NULL,
    [ProcessInfo] [nvarchar](128) NOT NULL,
    [LogText] [nvarchar](max) NOT NULL,
    [RecordStatus] [char] (1) NOT NULL,        -- record status - used to determine if the record is active or not
    [RecordCreated] [datetimeoffset] (7) NOT NULL   -- audit timestamp storing the date and time the record was created (is additional detail necessary?)
) ON [TABLES] TEXTIMAGE_ON [TABLES]
GO


-- default constraint on RecordStatus = "A"
ALTER TABLE [Staging].[ServerErrorLog] ADD CONSTRAINT
	DF_ServerErrorLog_RecordStatus DEFAULT 'A' FOR RecordStatus
GO

-- default constraint on RecordCreated = SYSDATETIMEOFFSET()
ALTER TABLE [Staging].[ServerErrorLog] ADD CONSTRAINT
	DF_ServerErrorLog_RecordCreated DEFAULT SYSDATETIMEOFFSET() FOR RecordCreated
GO


USE [master]
GO
