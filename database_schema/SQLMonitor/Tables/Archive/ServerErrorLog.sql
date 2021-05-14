USE [SQLMonitorArchive]
GO

IF OBJECT_ID('[Archive].[ServerErrorLog]') IS NOT NULL
BEGIN
    DROP TABLE [Archive].[ServerErrorLog];
END
GO

CREATE TABLE [Archive].[ServerErrorLog](
    [ServerErrorLogID] [int] NOT NULL,
	[ServerName] [nvarchar](128) NOT NULL,
	[LogDate] [datetime] NOT NULL,
    [ProcessInfo] [nvarchar](128) NOT NULL,
    [LogText] [nvarchar](max) NOT NULL,
    [RecordStatus] [char] (1) NOT NULL,        -- record status - used to determine if the record is active or not
    [RecordCreated] [datetimeoffset] (7) NOT NULL   -- audit timestamp storing the date and time the record was created (is additional detail necessary?)
) ON [TABLES] TEXTIMAGE_ON [TABLES]
GO


-- clustered index on ServerInfoID
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'[Archive].[ServerErrorLog]') AND name = N'PK_ServerErrorLog_Archive')
ALTER TABLE [Archive].[ServerErrorLog]
ADD  CONSTRAINT [PK_ServerErrorLog_Archive] PRIMARY KEY CLUSTERED ([ServerErrorLogID] ASC)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON, IGNORE_DUP_KEY = OFF, ONLINE = OFF, 
    ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [TABLES]
GO


USE [master]
GO
