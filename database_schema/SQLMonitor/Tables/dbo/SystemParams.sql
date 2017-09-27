USE [SQLMonitor]
GO

IF OBJECT_ID('[dbo].[SystemParams]') IS NOT NULL
DROP TABLE [dbo].[SystemParams]
GO

CREATE TABLE [dbo].[SystemParams] (
    [ParamID] [int] IDENTITY(1,1) NOT NULL,
    [ParamName] [nvarchar] (128) COLLATE Latin1_General_CI_AS NOT NULL,
    [ParamValue] [nvarchar] (4000) COLLATE Latin1_General_CI_AS NOT NULL,
    [ParamDescription] [nvarchar] (4000) COLLATE Latin1_General_CI_AS NOT NULL,
    [RecordStatus] [char] (1) NOT NULL,       -- record status - used to determine if the record is active or not
    [RecordCreated] [datetime2] (0) NOT NULL  -- audit timestamp storing the date and time the record was created (is additional detail necessary?)
) ON [TABLES]
GO

-- clustered index on ParamID
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[SystemParams]') AND name = N'PK_SystemParams')
ALTER TABLE [dbo].[SystemParams]
ADD  CONSTRAINT [PK_SystemParams] PRIMARY KEY CLUSTERED ([ParamID] ASC)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON, IGNORE_DUP_KEY = OFF, ONLINE = OFF, 
    ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [TABLES]
GO

-- default constraint on RecordStatus = "A"
ALTER TABLE [dbo].[SystemParams] ADD CONSTRAINT
	DF_SystemParams_RecordStatus DEFAULT 'A' FOR RecordStatus
GO
-- check constraint on RecordStatus - allowed values "A", "D", "H"
ALTER TABLE [dbo].[SystemParams] ADD CONSTRAINT
	CK_SystemParams_RecordStatus CHECK (RecordStatus LIKE '[ADH]')
GO

-- default constraint on RecordCreated = CURRENT_TIMESTAMP
ALTER TABLE [dbo].[SystemParams] ADD CONSTRAINT
	DF_SystemParams_RecordCreated DEFAULT CURRENT_TIMESTAMP FOR RecordCreated
GO

-- unique constraint on ParamName
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[SystemParams]') AND name = N'IX_SystemParams_ParamName')
CREATE UNIQUE NONCLUSTERED INDEX [IX_SystemParams_ParamName] 
ON [dbo].[SystemParams] ([ParamName] ASC)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON, DROP_EXISTING = OFF, ONLINE = OFF, 
    ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [TABLES]
GO

-- TRUNCATE TABLE [dbo].[SystemParams];
SET NOCOUNT ON;
-- data archival and retention params
INSERT INTO [dbo].[SystemParams] (
    [ParamName], [ParamValue], [ParamDescription], [RecordStatus], [RecordCreated])
VALUES 
    ('Archive_Days_DatabaseBackupHistory', '32', 'Backup history, incl. size, location, who, etc.', 'A', DEFAULT),
    ('Archive_Days_DatabaseConfigurations', '32', 'Database files, location, file sizes, growth params, etc.', 'A', DEFAULT),
    ('Archive_Days_DatabaseTables', '32', 'Table counts, data size and index size. Used for trending', 'A', DEFAULT),
    ('Archive_Days_DatabaseUsers', '32', 'Database users, membership in fixed database roles, etc.', 'A', DEFAULT),
    ('Archive_Days_ServerAgentConfig', '32', 'SQL Agent configuration', 'A', DEFAULT),
    ('Archive_Days_ServerAgentJobs', '32', 'Job name, status, timings, outcome, etc.', 'A', DEFAULT),
    ('Archive_Days_ServerConfigurations', '32', 'SQL Server configuration parameters', 'A', DEFAULT),
    ('Archive_Days_ServerDatabases', '32', 'List of databases and database settings', 'A', DEFAULT),
    ('Archive_Days_ServerEndpoints', '32', 'Server endpoints', 'A', DEFAULT),
    ('Archive_Days_ServerErrorLog', '32', 'A dump of the ERRORLOG', 'A', DEFAULT),
    ('Archive_Days_ServerFreeSpace', '32', 'Free space for all fixed drives. Used for trending', 'A', DEFAULT),
    ('Archive_Days_ServerInfo', '32', 'Server information such as edition, version, patch level, OS version, authentication method, memory, CPUs, etc.', 'A', DEFAULT),
    ('Archive_Days_ServerLogins', '32', 'Logins, membership in fixed server roles, etc.', 'A', DEFAULT),
    ('Archive_Days_ServerServers', '32', 'Linked servers and various related settings', 'A', DEFAULT),
    ('Archive_Days_ServerTriggers', '32', 'Triggers created as server level', 'A', DEFAULT),
    ('Archive_Days_ServerAgentJobsHistory', '32', 'SQL Agent Jobs history', 'A', DEFAULT),

    ('Delete_Days_DatabaseBackupHistory', '188', 'Backup history, incl. size, location, who, etc.', 'A', DEFAULT),
    ('Delete_Days_DatabaseConfigurations', '*** Never ***', 'Database files, location, file sizes, growth params, etc.', 'H', DEFAULT),
    ('Delete_Days_DatabaseTables', '1830', 'Table counts, data size and index size. Used for trending', 'A', DEFAULT),
    ('Delete_Days_DatabaseUsers', '188', 'Database users, membership in fixed database roles, etc.', 'A', DEFAULT),
    ('Delete_Days_ServerAgentConfig', '188', 'SQL Agent configuration', 'A', DEFAULT),
    ('Delete_Days_ServerAgentJobs', '188', 'Job name, status, timings, outcome, etc.', 'A', DEFAULT),
    ('Delete_Days_ServerConfigurations', '188', 'SQL Server configuration parameters', 'A', DEFAULT),
    ('Delete_Days_ServerDatabases', '366', 'List of databases and database settings', 'A', DEFAULT),
    ('Delete_Days_ServerEndpoints', '188', 'Server endpoints ', 'A', DEFAULT),
    ('Delete_Days_ServerErrorLog', '95', 'A dump of the ERRORLOG', 'A', DEFAULT),
    ('Delete_Days_ServerFreeSpace', '*** Never ***', 'Free space for all fixed drives. Used for trending', 'H', DEFAULT),
    ('Delete_Days_ServerInfo', '188', 'Server information such as edition, version, patch level, OS version, authentication method, memory, CPUs, etc.', 'A', DEFAULT),
    ('Delete_Days_ServerLogins', '188', 'Logins, membership in fixed server roles, etc.', 'A', DEFAULT),
    ('Delete_Days_ServerServers', '188', 'Linked servers and various related settings', 'A', DEFAULT),
    ('Delete_Days_ServerTriggers', '188', 'Triggers created as server level', 'A', DEFAULT),
    ('Delete_Days_ServerAgentJobsHistory', '188', 'SQL Agent Jobs history', 'A', DEFAULT)
GO

-- batch processing limits params
INSERT INTO [dbo].[SystemParams] (
    [ParamName], [ParamValue], [ParamDescription], [RecordStatus], [RecordCreated])
VALUES 
    ('Archive_BatchCount', '1000', 'Number of rows in each batch for the Archival process', 'A', DEFAULT),
    ('Delete_BatchCount', '1000', 'Number of rows in each batch for the Deletion process', 'A', DEFAULT)
GO

-- SQL Server build versions - used for automated reporting
INSERT INTO [dbo].[SystemParams] (
    [ParamName], [ParamValue], [ParamDescription], [RecordStatus], [RecordCreated])
VALUES 
	('SQLServer_BuildVersion_2005',	'9.0.5000.00', 'Latest build version for SQL Server 2005', 'A', CURRENT_TIMESTAMP),
	('SQLServer_BuildVersion_2008', '10.0.6000.29', 'Latest build version for SQL Server 2008', 'A', CURRENT_TIMESTAMP),
	('SQLServer_BuildVersion_2008R2', '10.50.6000.34', 'Latest build version for SQL Server 2008 R2', 'A', CURRENT_TIMESTAMP),
	('SQLServer_BuildVersion_2012', '11.0.6020.0', 'Latest build version for SQL Server 2012',	'A', CURRENT_TIMESTAMP),
	('SQLServer_BuildVersion_2014', '12.0.5000.0', 'Latest build version for SQL Server 2014',	'A', CURRENT_TIMESTAMP),
	('SQLServer_BuildVersion_2016', '13.0.4001.0', 'Latest build version for SQL Server 2016',	'A', CURRENT_TIMESTAMP)
GO

-- SELECT * FROM [dbo].[SystemParams]


USE [master]
GO
