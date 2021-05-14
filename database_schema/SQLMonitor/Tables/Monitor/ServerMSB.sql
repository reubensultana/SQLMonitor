USE [SQLMonitor]
GO

IF OBJECT_ID('[Monitor].[ServerMSB]') IS NOT NULL
BEGIN
    DROP TABLE [Monitor].[ServerMSB];
END
GO

CREATE TABLE [Monitor].[ServerMSB](
    [ServerMSBID] [int] IDENTITY(-2147483648,1) NOT NULL,
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


-- clustered index on ServerInfoID
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'[Monitor].[ServerMSB]') AND name = N'PK_ServerMSB')
ALTER TABLE [Monitor].[ServerMSB]
ADD  CONSTRAINT [PK_ServerMSB] PRIMARY KEY CLUSTERED ([ServerMSBID] ASC)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON, IGNORE_DUP_KEY = OFF, ONLINE = OFF, 
    ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [TABLES]
GO


-- default constraint on RecordStatus = "A"
ALTER TABLE [Monitor].[ServerMSB] ADD CONSTRAINT
	DF_ServerMSB_RecordStatus DEFAULT 'A' FOR RecordStatus
GO
-- check constraint on RecordStatus - allowed values "A", "D", "H"
ALTER TABLE [Monitor].[ServerMSB] ADD CONSTRAINT
	CK_ServerMSB_RecordStatus CHECK (RecordStatus LIKE '[ADH]')
GO

-- default constraint on RecordCreated = SYSDATETIMEOFFSET()
ALTER TABLE [Monitor].[ServerMSB] ADD CONSTRAINT
	DF_ServerMSB_RecordCreated DEFAULT SYSDATETIMEOFFSET() FOR RecordCreated
GO


USE [master]
GO
