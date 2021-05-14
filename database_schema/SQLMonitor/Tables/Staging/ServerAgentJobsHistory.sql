USE [SQLMonitor]
GO

IF OBJECT_ID('[Staging].[ServerAgentJobsHistory]') IS NOT NULL
BEGIN
    DROP TABLE [Staging].[ServerAgentJobsHistory];
END
GO

CREATE TABLE [Staging].[ServerAgentJobsHistory](
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
) ON [TABLES]
GO


-- default constraint on RecordStatus = "A"
ALTER TABLE [Staging].[ServerAgentJobsHistory] ADD CONSTRAINT
	DF_ServerAgentJobsHistory_RecordStatus DEFAULT 'A' FOR RecordStatus
GO

-- default constraint on RecordCreated = SYSDATETIMEOFFSET()
ALTER TABLE [Staging].[ServerAgentJobsHistory] ADD CONSTRAINT
	DF_ServerAgentJobsHistory_RecordCreated DEFAULT SYSDATETIMEOFFSET() FOR RecordCreated
GO


USE [master]
GO
