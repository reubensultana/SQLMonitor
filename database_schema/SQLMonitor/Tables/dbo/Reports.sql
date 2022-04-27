USE [SQLMonitor]
GO

IF OBJECT_ID('[dbo].[Reports]') IS NOT NULL
    DROP TABLE [dbo].[Reports];
GO

CREATE TABLE [dbo].[Reports] (
    [ReportID]          [int] IDENTITY(1,1) NOT NULL,
    [ReportName]        [varchar] (100) NOT NULL,   -- the actual report name as it will appear on the output
    [ReportType]        [varchar] (50) NOT NULL,    -- defines execution schedule: Monthly, Weekly, Daily, Manual, Custom Monthly, Custom Weekly, Custom Daily
    [PreExecuteScript]  [nvarchar] (4000) NOT NULL,   -- optional: script which should be run before every iteration of the main script; used to retrieve single values which can then be used in the main script.
    [ExecuteScript]     [nvarchar] (max) NOT NULL,     -- the actual script which will be executed with each iteration - if empty, the script file will be used instead
    [ExecutionOrder]    [tinyint] NOT NULL DEFAULT(0),
    [CreateChart]       [bit] NOT NULL DEFAULT(0),    -- flag to instruct PowerShell to create a chart with the results - requires a specific output format
    [RecordStatus]      [char] (1) NOT NULL,       -- record status - used to determine if the record is active or not
    [RecordCreated]     [datetime2] (0) NOT NULL  -- audit timestamp storing the date and time the record was created (is additional detail necessary?)
) ON [TABLES]
GO


-- clustered index on ReportID
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[Reports]') AND name = N'PK_Report')
ALTER TABLE [dbo].[Reports]
ADD  CONSTRAINT [PK_Report] PRIMARY KEY CLUSTERED ([ReportID] ASC)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON, IGNORE_DUP_KEY = OFF, ONLINE = OFF, 
    ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [TABLES]
GO


-- default constraint on RecordStatus = "A"
ALTER TABLE [dbo].[Reports] ADD CONSTRAINT
	DF_Report_RecordStatus DEFAULT 'A' FOR RecordStatus
GO
-- check constraint on RecordStatus - allowed values "A", "D", "H"
ALTER TABLE [dbo].[Reports] ADD CONSTRAINT
	CK_Report_RecordStatus CHECK (RecordStatus LIKE '[ADH]')
GO

-- default constraint on RecordCreated = SYSDATETIMEOFFSET()
ALTER TABLE [dbo].[Reports] ADD CONSTRAINT
	DF_Report_RecordCreated DEFAULT SYSDATETIMEOFFSET() FOR RecordCreated
GO

-- default constraint on PreExecuteScript = ""
ALTER TABLE [dbo].[Reports] ADD CONSTRAINT
	DF_Report_PreExecuteScript DEFAULT N'' FOR [PreExecuteScript]
GO

-- default constraint on ExecuteScript = ""
ALTER TABLE [dbo].[Reports] ADD CONSTRAINT
	DF_Report_ExecuteScript DEFAULT N'' FOR [ExecuteScript]
GO


USE [master]
GO
