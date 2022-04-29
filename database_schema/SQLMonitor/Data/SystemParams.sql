/* ----- dbo.SystemParams ----- */
-- TRUNCATE TABLE [dbo].[SystemParams];
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
	('SQLServer_BuildVersion_2000',     '8.0.2305.0',   'Latest build version for SQL Server 2000',     'A', DEFAULT),
    ('SQLServer_BuildVersion_2005',	    '9.0.5324.0',   'Latest build version for SQL Server 2005',     'A', DEFAULT),
	('SQLServer_BuildVersion_2008',     '10.0.6556.0',  'Latest build version for SQL Server 2008',     'A', DEFAULT),
	('SQLServer_BuildVersion_2008R2',   '10.50.6560.0', 'Latest build version for SQL Server 2008 R2',  'A', DEFAULT),
	('SQLServer_BuildVersion_2012',     '11.0.7001.0',  'Latest build version for SQL Server 2012',	    'A', DEFAULT),
	('SQLServer_BuildVersion_2014',     '12.0.6329.1',  'Latest build version for SQL Server 2014',	    'A', DEFAULT),
	('SQLServer_BuildVersion_2016',     '13.0.5850.14', 'Latest build version for SQL Server 2016',	    'A', DEFAULT),
    ('SQLServer_BuildVersion_2017',     '14.0.3356.20', 'Latest build version for SQL Server 2017',	    'A', DEFAULT),
    ('SQLServer_BuildVersion_2019',     '15.0.4073.23', 'Latest build version for SQL Server 2019',	    'A', DEFAULT)
GO

-- Schema name used for Staging purposes....???!!!
INSERT INTO [dbo].[SystemParams] (
    [ParamName], [ParamValue], [ParamDescription], [RecordStatus], [RecordCreated])
VALUES 
    ('SchemaName_Staging', 'Staging', 'Schema name used for Staging purposes', 'A', DEFAULT);
GO

-- SELECT * FROM [dbo].[SystemParams] ORDER BY [ParamName]
