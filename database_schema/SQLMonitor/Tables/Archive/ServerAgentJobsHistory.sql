IF OBJECT_ID('[Archive].[ServerAgentJobsHistory]') IS NOT NULL
DROP TABLE [Archive].[ServerAgentJobsHistory];
GO

CREATE TABLE [Archive].[ServerAgentJobsHistory](
    [ServerAgentJobsHistoryID] [int] NOT NULL,
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
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'[Archive].[ServerAgentJobsHistory]') AND name = N'PK_ServerAgentJobsHistory_Archive')
ALTER TABLE [Archive].[ServerAgentJobsHistory]
ADD  CONSTRAINT [PK_ServerAgentJobsHistory_Archive] PRIMARY KEY CLUSTERED ([ServerAgentJobsHistoryID] ASC)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON, IGNORE_DUP_KEY = OFF, ONLINE = OFF, 
    ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100)
GO
