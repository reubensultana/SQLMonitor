USE [SQLMonitor]
GO

IF OBJECT_ID('[dbo].[Profile]') IS NOT NULL
    DROP TABLE [dbo].[Profile];
GO

CREATE TABLE [dbo].[Profile] (
    [ProfileID] [int] IDENTITY(1,1) NOT NULL,
    [ProfileName] [varchar](50) NOT NULL,   -- equivalent to the destination schema name
    [ScriptName] [nvarchar](255) NOT NULL,  -- equivalent to the destination table name
    [ProfileType] [varchar](50) NOT NULL,   -- defines execution schedule: Manual, Recurrent, Daily, Weekly, Monthly
    [PreExecuteScript] [nvarchar](4000) NOT NULL,   -- optional: script which should be run before every iteration of the main script; used to retrieve single values which can then be used in the main script.
    [ExecuteScript] nvarchar(max) NOT NULL,     -- the actual script which will be executed with each iteration - if empty, the script file will be used instead
--    [IntervalMinutes] int NOT NULL,         -- the number of minutes which have to elapse to execute this script
    [ExecutionOrder] [tinyint] NOT NULL DEFAULT(0),
    [RecordStatus] [char] (1) NOT NULL,       -- record status - used to determine if the record is active or not
    [RecordCreated] [datetime2] (0) NOT NULL  -- audit timestamp storing the date and time the record was created (is additional detail necessary?)
) ON [TABLES]
GO


-- clustered index on ProfileID
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[Profile]') AND name = N'PK_Profile')
ALTER TABLE [dbo].[Profile]
ADD  CONSTRAINT [PK_Profile] PRIMARY KEY CLUSTERED ([ProfileID] ASC)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON, IGNORE_DUP_KEY = OFF, ONLINE = OFF, 
    ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [TABLES]
GO

/*
-- default constraint on IntervalMinutes = 0
ALTER TABLE [dbo].[Profile] ADD CONSTRAINT
	DF_Profile_IntervalMinutes DEFAULT (0) FOR IntervalMinutes
GO
*/

-- default constraint on RecordStatus = "A"
ALTER TABLE [dbo].[Profile] ADD CONSTRAINT
	DF_Profile_RecordStatus DEFAULT 'A' FOR RecordStatus
GO
-- check constraint on RecordStatus - allowed values "A", "D", "H"
ALTER TABLE [dbo].[Profile] ADD CONSTRAINT
	CK_Profile_RecordStatus CHECK (RecordStatus LIKE '[ADH]')
GO

-- default constraint on RecordCreated = CURRENT_TIMESTAMP
ALTER TABLE [dbo].[Profile] ADD CONSTRAINT
	DF_Profile_RecordCreated DEFAULT CURRENT_TIMESTAMP FOR RecordCreated
GO

-- Manual, Recurrent, Daily, Weekly, Monthly
-- generate initial data set
INSERT INTO [dbo].[Profile] (ProfileName, ScriptName, ExecutionOrder, ProfileType, PreExecuteScript, ExecuteScript) --, IntervalMinutes)
VALUES
     ('Monitor', 'server_info',                 1, 'Monthly',   N'', N'')
    ,('Monitor', 'server_logins',               2, 'Monthly',   N'', N'')
    ,('Monitor', 'server_databases',            3, 'Monthly',   N'', N'')
    ,('Monitor', 'server_configurations',       4, 'Monthly',   N'', N'')
    ,('Monitor', 'server_servers',              5, 'Monthly',   N'', N'')
    ,('Monitor', 'server_triggers',             6, 'Monthly',   N'', N'')
    ,('Monitor', 'server_endpoints',            7, 'Monthly',   N'', N'')
    ,('Monitor', 'database_configurations',     1, 'Weekly',    N'', N'')
    ,('Monitor', 'database_users',              2, 'Weekly',    N'', N'')
    ,('Monitor', 'database_tables',             3, 'Weekly',    N'', N'')
    ,('Monitor', 'server_errorlog',             1, 'Manual',    N'USE [SQLMonitor]; SELECT COALESCE(CONVERT(varchar(25), MAX([LogDate]), 121), ''1753-01-01 00:00:00'') AS [Output] FROM [Monitor].[ServerErrorLog] WHERE [ServerName] = ''{0}'';', N'')
GO

/*
yy - year
mm - month
ww - week
dd - day
hh - hour
nn - minute
ot - one-time
*/

USE [master]
GO
