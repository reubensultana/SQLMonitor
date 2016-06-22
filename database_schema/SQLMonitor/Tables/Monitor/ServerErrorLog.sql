USE [SQLMonitor]
GO

IF OBJECT_ID('[Monitor].[ServerErrorLog]') IS NOT NULL
BEGIN
    DROP TABLE [Monitor].[ServerErrorLog];
END
GO

CREATE TABLE [Monitor].[ServerErrorLog](
    [ServerErrorLogID] [int] IDENTITY(-2147483648,1) NOT NULL,
	[ServerName] [nvarchar](128) NOT NULL,
	[LogDate] [datetime] NOT NULL,
    [ProcessInfo] [nvarchar](128) NOT NULL,
    [LogText] [varchar](max) NOT NULL,
    [RecordStatus] [char] (1) NOT NULL,        -- record status - used to determine if the record is active or not
    [RecordCreated] [datetime2] (0) NOT NULL   -- audit timestamp storing the date and time the record was created (is additional detail necessary?)
) ON [TABLES] TEXTIMAGE_ON [TABLES]
GO


-- clustered index on ServerInfoID
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'[Monitor].[ServerErrorLog]') AND name = N'PK_ServerErrorLog')
ALTER TABLE [Monitor].[ServerErrorLog]
ADD  CONSTRAINT [PK_ServerErrorLog] PRIMARY KEY CLUSTERED ([ServerErrorLogID] ASC)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON, IGNORE_DUP_KEY = OFF, ONLINE = OFF, 
    ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [TABLES]
GO


-- default constraint on RecordStatus = "A"
ALTER TABLE [Monitor].[ServerErrorLog] ADD CONSTRAINT
	DF_ServerErrorLog_RecordStatus DEFAULT 'A' FOR RecordStatus
GO
-- check constraint on RecordStatus - allowed values "A", "D", "H"
ALTER TABLE [Monitor].[ServerErrorLog] ADD CONSTRAINT
	CK_ServerErrorLog_RecordStatus CHECK (RecordStatus LIKE '[ADH]')
GO

-- default constraint on RecordCreated = CURRENT_TIMESTAMP
ALTER TABLE [Monitor].[ServerErrorLog] ADD CONSTRAINT
	DF_ServerErrorLog_RecordCreated DEFAULT CURRENT_TIMESTAMP FOR RecordCreated
GO


USE [master]
GO
