IF OBJECT_ID('[Monitor].[ServerAgentConfig]') IS NOT NULL
DROP TABLE [Monitor].[ServerAgentConfig];
GO

CREATE TABLE [Monitor].[ServerAgentConfig](
    [ServerAgentConfigID] [int] IDENTITY(-2147483648,1) NOT NULL,
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
)
GO


-- clustered index on ServerInfoID
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'[Monitor].[ServerAgentConfig]') AND name = N'PK_ServerAgentConfig')
ALTER TABLE [Monitor].[ServerAgentConfig]
ADD  CONSTRAINT [PK_ServerAgentConfig] PRIMARY KEY CLUSTERED ([ServerAgentConfigID] ASC)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON, IGNORE_DUP_KEY = OFF, ONLINE = OFF, 
    ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100)
GO


-- default constraint on RecordStatus = "A"
ALTER TABLE [Monitor].[ServerAgentConfig] ADD CONSTRAINT
	DF_ServerAgentConfig_RecordStatus DEFAULT 'A' FOR RecordStatus
GO
-- check constraint on RecordStatus - allowed values "A", "D", "H"
ALTER TABLE [Monitor].[ServerAgentConfig] ADD CONSTRAINT
	CK_ServerAgentConfig_RecordStatus CHECK (RecordStatus LIKE '[ADH]')
GO

-- default constraint on RecordCreated = SYSDATETIMEOFFSET()
ALTER TABLE [Monitor].[ServerAgentConfig] ADD CONSTRAINT
	DF_ServerAgentConfig_RecordCreated DEFAULT SYSDATETIMEOFFSET() FOR RecordCreated
GO
