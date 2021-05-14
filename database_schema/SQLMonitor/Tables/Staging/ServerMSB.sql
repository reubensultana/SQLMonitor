USE [SQLMonitor]
GO

IF OBJECT_ID('[Staging].[ServerMSB]') IS NOT NULL
BEGIN
    DROP TABLE [Staging].[ServerMSB];
END
GO

CREATE TABLE [Staging].[ServerMSB](
	[ServerName] [nvarchar](128) NOT NULL,
    [MSBID] [varchar](10) NOT NULL,
    [MSBName] [varchar](255) NOT NULL,
    [MSBCheck] [varchar](255) NOT NULL,
    [MSBResult] [nvarchar](128) NULL,
    [MSBCompliant] [smallint] NULL,
    [RecordStatus] [char] (1) NOT NULL,         -- record status - used to determine if the record is active or not
    [RecordCreated] [datetimeoffset] (7) NOT NULL    -- audit timestamp storing the date and time the record was created (is additional detail necessary?)
) ON [TABLES]
GO


-- default constraint on RecordStatus = "A"
ALTER TABLE [Staging].[ServerMSB] ADD CONSTRAINT
	DF_ServerMSB_RecordStatus DEFAULT 'A' FOR RecordStatus
GO

-- default constraint on RecordCreated = SYSDATETIMEOFFSET()
ALTER TABLE [Staging].[ServerMSB] ADD CONSTRAINT
	DF_ServerMSB_RecordCreated DEFAULT SYSDATETIMEOFFSET() FOR RecordCreated
GO


USE [master]
GO
