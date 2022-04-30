IF OBJECT_ID('[Monitor].[ServerAgentJobsHistory]') IS NOT NULL
DROP TABLE [Monitor].[ServerAgentJobsHistory];
GO

CREATE TABLE [Monitor].[ServerAgentJobsHistory](
    [ServerAgentJobsHistoryID] [int] IDENTITY(-2147483648,1) NOT NULL,
	[ServerName] [nvarchar](128) NOT NULL,
    [JobID] [uniqueidentifier] NOT NULL,
    [JobName] [nvarchar](128) NOT NULL,
    [StepID] [int] NOT NULL,
    [StepName] [nvarchar](128) NOT NULL,
    [LastRunTime] [datetime] NULL,
    [RunStatus] [int] NOT NULL,
    [Message] [nvarchar](4000) NOT NULL,
    [RecordStatus] [char] (1) NOT NULL,        -- record status - used to determine if the record is active or not
    [RecordCreated] [datetimeoffset] (7) NOT NULL   -- audit timestamp storing the date and time the record was created (is additional detail necessary?)
)
GO


-- clustered index on ServerInfoID
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'[Monitor].[ServerAgentJobsHistory]') AND name = N'PK_ServerAgentJobsHistory')
ALTER TABLE [Monitor].[ServerAgentJobsHistory]
ADD  CONSTRAINT [PK_ServerAgentJobsHistory] PRIMARY KEY CLUSTERED ([ServerAgentJobsHistoryID] ASC)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON, IGNORE_DUP_KEY = OFF, ONLINE = OFF, 
    ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100)
GO

-- indexes created for performance
CREATE NONCLUSTERED INDEX [IX_ServerAgentJobsHistory_ServerName]
ON [Monitor].[ServerAgentJobsHistory] ([ServerName], [RecordStatus])
INCLUDE ([LastRunTime], [RecordCreated]) 
WITH (
    PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON, IGNORE_DUP_KEY = OFF, 
    DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90
)
GO

CREATE NONCLUSTERED INDEX [IX_ServerAgentJobsHistory_LastRunTime_RunStatus]
ON [Monitor].[ServerAgentJobsHistory] ([LastRunTime],[RunStatus])
INCLUDE ([ServerName],[JobName],[StepID],[StepName])
WITH (
    PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON, IGNORE_DUP_KEY = OFF, 
    DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100
)
GO

-- default constraint on RecordStatus = "A"
ALTER TABLE [Monitor].[ServerAgentJobsHistory] ADD CONSTRAINT
	DF_ServerAgentJobsHistory_RecordStatus DEFAULT 'A' FOR RecordStatus
GO
-- check constraint on RecordStatus - allowed values "A", "D", "H"
ALTER TABLE [Monitor].[ServerAgentJobsHistory] ADD CONSTRAINT
	CK_ServerAgentJobsHistory_RecordStatus CHECK (RecordStatus LIKE '[ADH]')
GO

-- default constraint on RecordCreated = SYSDATETIMEOFFSET()
ALTER TABLE [Monitor].[ServerAgentJobsHistory] ADD CONSTRAINT
	DF_ServerAgentJobsHistory_RecordCreated DEFAULT SYSDATETIMEOFFSET() FOR RecordCreated
GO
