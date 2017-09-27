USE [SQLMonitor]
GO

IF OBJECT_ID('[Monitor].[ServerAgentJobs]') IS NOT NULL
BEGIN
    DROP TABLE [Monitor].[ServerAgentJobs];
END
GO

CREATE TABLE [Monitor].[ServerAgentJobs](
    [ServerAgentJobsID] [int] IDENTITY(-2147483648,1) NOT NULL,
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
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'[Monitor].[ServerAgentJobs]') AND name = N'PK_ServerAgentJobs')
ALTER TABLE [Monitor].[ServerAgentJobs]
ADD  CONSTRAINT [PK_ServerAgentJobs] PRIMARY KEY CLUSTERED ([ServerAgentJobsID] ASC)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON, IGNORE_DUP_KEY = OFF, ONLINE = OFF, 
    ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [TABLES]
GO


-- default constraint on RecordStatus = "A"
ALTER TABLE [Monitor].[ServerAgentJobs] ADD CONSTRAINT
	DF_ServerAgentJobs_RecordStatus DEFAULT 'A' FOR RecordStatus
GO
-- check constraint on RecordStatus - allowed values "A", "D", "H"
ALTER TABLE [Monitor].[ServerAgentJobs] ADD CONSTRAINT
	CK_ServerAgentJobs_RecordStatus CHECK (RecordStatus LIKE '[ADH]')
GO

-- default constraint on RecordCreated = CURRENT_TIMESTAMP
ALTER TABLE [Monitor].[ServerAgentJobs] ADD CONSTRAINT
	DF_ServerAgentJobs_RecordCreated DEFAULT CURRENT_TIMESTAMP FOR RecordCreated
GO


USE [master]
GO
