USE [SQLMonitor]
GO

IF OBJECT_ID('[dbo].[Reports]') IS NOT NULL
    DROP TABLE [dbo].[Reports];
GO

CREATE TABLE [dbo].[Reports] (
    [ReportID] [int] IDENTITY(1,1) NOT NULL,
    [ReportName] [varchar](50) NOT NULL,    -- the actual report name as it will appear on the output
    [ReportType] [varchar](50) NOT NULL,    -- defines execution schedule: Monthly, Weekly, Daily, Manual, Custom Monthly, Custom Weekly, Custom Daily
    [PreExecuteScript] [nvarchar](4000) NOT NULL,   -- optional: script which should be run before every iteration of the main script; used to retrieve single values which can then be used in the main script.
    [ExecuteScript] nvarchar(max) NOT NULL,     -- the actual script which will be executed with each iteration - if empty, the script file will be used instead
    [ExecutionOrder] [tinyint] NOT NULL DEFAULT(0),
    [CreateChart] [bit] NOT NULL DEFAULT(0),    -- flag to instruct PowerShell to create a chart with the results - requires a specific output format
    [RecordStatus] [char] (1) NOT NULL,       -- record status - used to determine if the record is active or not
    [RecordCreated] [datetime2] (0) NOT NULL  -- audit timestamp storing the date and time the record was created (is additional detail necessary?)
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

-- default constraint on RecordCreated = CURRENT_TIMESTAMP
ALTER TABLE [dbo].[Reports] ADD CONSTRAINT
	DF_Report_RecordCreated DEFAULT CURRENT_TIMESTAMP FOR RecordCreated
GO

-- default constraint on PreExecuteScript = ""
ALTER TABLE [dbo].[Reports] ADD CONSTRAINT
	DF_Report_PreExecuteScript DEFAULT N'' FOR [PreExecuteScript]
GO

-- default constraint on ExecuteScript = ""
ALTER TABLE [dbo].[Reports] ADD CONSTRAINT
	DF_Report_ExecuteScript DEFAULT N'' FOR [ExecuteScript]
GO


-- generate initial data set
-- ---------------------------------------------
-- TRUNCATE TABLE [dbo].[Reports];
SET IDENTITY_INSERT [dbo].[Reports] ON;
GO
INSERT INTO [dbo].[Reports] (
    ReportID, ReportName, ReportType, ExecutionOrder, PreExecuteScript, ExecuteScript, CreateChart, RecordStatus
    )
VALUES
     (1,    'Failed Agent Jobs',        'Daily',        1,  '', 'EXEC [Reporting].[uspFailedServerAgentJobs];', 0, 'A')
    ,(2,    'Failed Login Attempts',    'Daily',        1,  '', 'EXEC [Reporting].[uspListFailedLogins];', 0, 'A')
    ,(3,    'Login List (sysadmins)',   'Monthly',      1,  '', 'EXEC [Reporting].[uspListServerLogins] @RoleName=''sysadmin'';', 0, 'A')
    ,(4,    'SQL Server Builds',        'Monthly',      1,  '', 'EXEC [Reporting].[uspReportSQLBuilds];', 0, 'A')

GO
SET IDENTITY_INSERT [dbo].[Reports] OFF
GO

/*
-- EXAMPLES:
-- ----------
-- Daily
EXEC [Reporting].[uspFailedServerAgentJobs];
EXEC [Reporting].[uspListFailedLogins];
-- Monthly
EXEC [Reporting].[uspListServerLogins] @RoleName='sysadmin';
EXEC [Reporting].[uspReportSQLBuilds];
-- Custom
EXEC [Reporting].[uspFailedServerAgentJobs] @ServerName = 'MyServer';
EXEC [Reporting].[uspListServerFreeSpaceTrend] @ServerName='MyServer';
EXEC [Reporting].[uspListDatabaseGrowthTrend] @ServerName='MyServer', @DatabaseName='AdventureWorks';
EXEC [Reporting].[uspListFailedLogins] @ServerName='MyServer';
EXEC [Reporting].[uspListServerLogins] @ServerName='MyServer', @RoleName='sysadmin';
*/

/*
-- NOTE: Watch out for single quotes in the PreExecuteScript and ExecuteScript columns
SELECT 
    ',(' + CAST(ReportID AS varchar(10)) + ',''' + ReportName + ''',''' + ReportType + ''',' + CAST(ExecutionOrder AS varchar(10)) + ',''' + 
    COALESCE(PreExecuteScript, '') + ''',''' + COALESCE(ExecuteScript, '') + ''')'
FROM [SQLMonitor].[dbo].[Reports]
ORDER BY ReportID
*/


USE [master]
GO
