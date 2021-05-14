USE [SQLMonitor]
GO

IF OBJECT_ID('[Staging].[ServerAgentJobs]') IS NOT NULL
BEGIN
    DROP TABLE [Staging].[ServerAgentJobs];
END
GO

CREATE TABLE [Staging].[ServerAgentJobs](
	[ServerName] [nvarchar](128) NOT NULL,
    [JobID] [uniqueidentifier] NOT NULL,
    [JobName] [nvarchar](128) NOT NULL,
    [Enabled] [tinyint] NOT NULL,
    [JobOwner] [nvarchar](128) NOT NULL,
    [DateCreated] [datetime] NOT NULL,
    [DateModified] [datetime] NOT NULL,
    [JobSteps] [XML] NULL,
    [JobSchedules] [XML] NULL,
    [RecordStatus] [char] (1) NOT NULL,        -- record status - used to determine if the record is active or not
    [RecordCreated] [datetimeoffset] (7) NOT NULL   -- audit timestamp storing the date and time the record was created (is additional detail necessary?)
) ON [TABLES]
GO


-- default constraint on RecordStatus = "A"
ALTER TABLE [Staging].[ServerAgentJobs] ADD CONSTRAINT
	DF_ServerAgentJobs_RecordStatus DEFAULT 'A' FOR RecordStatus
GO

-- default constraint on RecordCreated = SYSDATETIMEOFFSET()
ALTER TABLE [Staging].[ServerAgentJobs] ADD CONSTRAINT
	DF_ServerAgentJobs_RecordCreated DEFAULT SYSDATETIMEOFFSET() FOR RecordCreated
GO


USE [master]
GO
