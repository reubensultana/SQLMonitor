USE [SQLMonitorArchive]
GO

IF OBJECT_ID('[Archive].[ServerAgentJobs]') IS NOT NULL
BEGIN
    DROP TABLE [Archive].[ServerAgentJobs];
END
GO

CREATE TABLE [Archive].[ServerAgentJobs](
    [ServerAgentJobsID] [int] NOT NULL,
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
    [RecordCreated] [datetime2] (0) NOT NULL   -- audit timestamp storing the date and time the record was created (is additional detail necessary?)
) ON [TABLES]
GO


-- clustered index on ServerInfoID
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'[Archive].[ServerAgentJobs]') AND name = N'PK_ServerAgentJobs_Archive')
ALTER TABLE [Archive].[ServerAgentJobs]
ADD  CONSTRAINT [PK_ServerAgentJobs_Archive] PRIMARY KEY CLUSTERED ([ServerAgentJobsID] ASC)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON, IGNORE_DUP_KEY = OFF, ONLINE = OFF, 
    ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [TABLES]
GO


USE [master]
GO
