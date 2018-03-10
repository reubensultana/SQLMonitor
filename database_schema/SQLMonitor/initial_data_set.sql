USE [SQLMonitor]
GO
SET NOCOUNT ON;

/* ----- dbo.MonitoredServers ----- */
/*
SET NOCOUNT ON;
SELECT ',(N''' + ServerName + ''', ' + COALESCE('''' + ServerAlias + '''', 'NULL') + ', ''' + ServerDescription + ''', ''' + 
    ServerIpAddress + ''', ''' + ServerDomain + ''', ' + CAST(SqlTcpPort AS varchar(10)) + ', ' + CAST(ServerOrder as varchar(10)) + ', ' + 
    CAST(SqlVersion AS varchar(10)) + ', ''' + RecordStatus + ''')'
FROM [SQLMonitor].[dbo].[MonitoredServers]
ORDER BY ServerOrder, ServerName
*/

-- TRUNCATE TABLE [dbo].[MonitoredServers];
INSERT INTO [dbo].[MonitoredServers] (
    ServerName, ServerAlias, ServerDescription, ServerIpAddress, ServerDomain, SqlTcpPort, ServerOrder, SqlVersion, RecordStatus )
VALUES 
     (N'SRVR01', NULL, '', '10.11.12.10', 'CONTOSO', 1433, 5, 12.00, 'A')
    ,(N'SRVR02', NULL, '', '10.11.12.11', 'CONTOSO', 1433, 5, 12.00, 'A')
    ,(N'SRVR03', NULL, '', '10.11.12.12', 'CONTOSO', 1433, 5, 12.00, 'A')
    ,(N'SRVR04', NULL, '', '10.11.12.13', 'CONTOSO', 1433, 5, 12.00, 'A')
    ,(N'SRVR05', NULL, '', '10.11.12.14', 'CONTOSO', 1433, 5, 12.00, 'A')
    ,(N'SRVR06', NULL, '', '10.11.12.15', 'CONTOSO', 1433, 5, 12.00, 'A')
    ,(N'SRVR07', NULL, '', '10.11.12.16', 'CONTOSO', 1433, 5, 12.00, 'A')

GO

-- SELECT * FROM [dbo].[MonitoredServers] ORDER BY ServerOrder, ServerName
/* -------------------------------------------------- */


/* ----- dbo.Profile ----- */
/*
-- NOTE: Watch out for single quotes in the PreExecuteScript and ExecuteScript columns
SELECT 
    ',(''' + ProfileName + ''',''' + ScriptName + ''',''' + CAST(ExecutionOrder AS varchar(10)) + ''',''' + ProfileType + ''',''' + 
    COALESCE(PreExecuteScript, '') + ''',''' + COALESCE(ExecuteScript, '') + ''')'
FROM [SQLMonitor].[dbo].[Profile]
ORDER BY ProfileType, ExecutionOrder, ProfileName, ScriptName
*/

-- NOTE: variable mappings for the "PreExecuteScript" column:
--     {0} => ServerName
-- ---------------------------------------------
-- TRUNCATE TABLE [dbo].[Profile];
INSERT INTO [dbo].[Profile] (
    ProfileName, ScriptName, ExecutionOrder, ProfileType, PreExecuteScript, ExecuteScript )
VALUES
    ('Monitor','server_agentjobs','1','Daily','','')
    ,('Monitor','database_backup_history','2','Daily','USE [SQLMonitor]; SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED; SELECT COALESCE(CONVERT(varchar(25), MAX([StartDate]), 121), (CONVERT(varchar(7), DATEADD(month, -3, CURRENT_TIMESTAMP), 121)+''-01'')) AS [Output] FROM [Monitor].[DatabaseBackupHistory] WHERE [ServerName] = ''{0}'';','')
    ,('Monitor','database_indexusagestats','3','Daily','USE [SQLMonitor]; TRUNCATE TABLE [Staging].[IndexUsageStats];','')
    ,('Monitor','database_missingindexstats','4','Daily','USE [SQLMonitor]; TRUNCATE TABLE [Staging].[MissingIndexStats];','')

    ,('Monitor','server_errorlog','1','Hourly','USE [SQLMonitor]; SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED; SELECT COALESCE(CONVERT(varchar(25), MAX([LogDate]), 121), ''1753-01-01 00:00:00'') AS [Output] FROM [Monitor].[ServerErrorLog] WHERE [ServerName] = ''{0}'';','')
    
    ,('Monitor','blitz_results','0','Manual','USE [SQLMonitor]; DELETE FROM [Monitor].[BlitzResults] WHERE [ServerName] = ''{0}'';','')
    
    ,('Monitor','server_agentjobshistory','1','Minute','USE [SQLMonitor]; SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED; SELECT COALESCE(CONVERT(varchar(25), MAX([LastRunTime]), 121), ''1753-01-01 00:00:00'') AS [Output] FROM [Monitor].[ServerAgentJobsHistory] WHERE [ServerName] = ''{0}'';','')
    
    ,('Monitor','server_info','1','Monthly','','')
    ,('Monitor','server_logins','2','Monthly','','')
    ,('Monitor','server_databases','3','Monthly','','')
    ,('Monitor','server_configurations','4','Monthly','','')
    ,('Monitor','server_servers','5','Monthly','','')
    ,('Monitor','server_triggers','6','Monthly','','')
    ,('Monitor','server_endpoints','7','Monthly','','')
    ,('Monitor','server_agentconfig','8','Monthly','','')
    ,('Monitor','database_table_columns','9','Monthly','USE [SQLMonitor]; DELETE FROM [Monitor].[DatabaseTableColumns] WHERE [ServerName] = ''{0}'';','')
    
    ,('Monitor','database_configurations','1','Weekly','','')
    ,('Monitor','database_users','2','Weekly','','')
    ,('Monitor','database_tables','3','Weekly','','')
    ,('Monitor','server_freespace','4','Weekly','','')
GO

-- SELECT * FROM [dbo].[Profile]
/* -------------------------------------------------- */


/* ----- dbo.Reports ----- */
/*
-- NOTE: Watch out for single quotes in the PreExecuteScript and ExecuteScript columns
SELECT 
    ',(' + CAST(ReportID AS varchar(10)) + ',''' + ReportName + ''',''' + ReportType + ''',' + CAST(ExecutionOrder AS varchar(10)) + ',''' + 
    COALESCE(PreExecuteScript, '') + ''',''' + COALESCE(ExecuteScript, '') + ''')'
FROM [SQLMonitor].[dbo].[Reports]
ORDER BY ReportID
*/

-- TRUNCATE TABLE [dbo].[Reports];
SET IDENTITY_INSERT [dbo].[Reports] ON;
GO
INSERT INTO [dbo].[Reports] (
    ReportID, ReportName, ReportType, ExecutionOrder, PreExecuteScript, ExecuteScript, CreateChart, RecordStatus
    )
VALUES
    (1,'Failed Agent Jobs','Daily',1,'','EXEC [Reporting].[uspFailedServerAgentJobs];', 0, 'A')
    ,(2,'Failed Login Attempts','Daily',1,'','EXEC [Reporting].[uspListFailedLogins];', 0, 'A')
    ,(3,'Login List (sysadmins)','Monthly',1,'','EXEC [Reporting].[uspListServerLogins] @RoleName=''sysadmin'';', 0, 'A')
    ,(4,'SQL Server Builds','Monthly',1,'','EXEC [Reporting].[uspReportSQLBuilds];', 0, 'A')
    ,(5,'Failed Agent Jobs (SRVR01)','Custom Daily',1,'','EXEC [Reporting].[uspFailedServerAgentJobs] @ServerName = ''SRVR01'';', 0, 'A')
    ,(6,'Failed Agent Jobs (SRVR02)','Custom Daily',1,'','EXEC [Reporting].[uspFailedServerAgentJobs] @ServerName = ''SRVR02'';', 0, 'A')
    ,(7,'Database Growth Trend (SRVR01: All)','Custom Weekly',1,'','EXEC [Reporting].[uspListDatabaseGrowthTrend] @ServerName=''SRVR01'', @DatabaseName=''%'', @IncludeArchive = 1, @ArchiveMonths = 4, @IncludeSystem = 0;', 0, 'A')
    ,(8,'Database Growth Trend (SRVR02: All)','Custom Weekly',1,'','EXEC [Reporting].[uspListDatabaseGrowthTrend] @ServerName=''SRVR02'', @DatabaseName=''%'', @IncludeArchive = 1, @ArchiveMonths = 4, @IncludeSystem = 0;', 0, 'A')
    ,(9,'Free Space Trend (SRVR02: All)','Custom Weekly',1,'','EXEC [Reporting].[uspListServerFreeSpaceTrend] @ServerName=''SRVR01'', @DriveLetter = ''%'';', 0, 'A')
    ,(10,'Database Growth Trend (SRVR03: All)','Custom Weekly',1,'','EXEC [Reporting].[uspListDatabaseGrowthTrend] @ServerName=''SRVR03'', @DatabaseName=''%'', @IncludeArchive = 1, @ArchiveMonths = 4, @IncludeSystem = 0;', 0, 'A')
GO
SET IDENTITY_INSERT [dbo].[Reports] OFF
GO

-- START: sp_Blitz reports
SET IDENTITY_INSERT [dbo].[Reports] ON;
GO
INSERT INTO [dbo].[Reports] (
    ReportID, ReportName, ReportType, ExecutionOrder, PreExecuteScript, ExecuteScript, CreateChart, RecordStatus
    )
VALUES
    --(12,'Outdated sp_Blitz: sp_Blitz is Over 6 Months Old','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 0, @CheckID = 155;', 0, 'H')
    --,(13,'Informational: @CheckUserDatabaseObjects Disabled','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 0, @CheckID = 204;', 0, 'H')
    (14,'Backup: Backups Not Performed Recently','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 1, @CheckID = 1;', 0, 'H')
    ,(15,'Backup: Full Recovery Mode w/o Log Backups','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 1, @CheckID = 2;', 0, 'H')
    ,(16,'Corruption: Database Corruption Detected','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 1, @CheckID = 34;', 0, 'H')
    ,(17,'Performance: Memory Dangerously Low','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 1, @CheckID = 51;', 0, 'H')
    ,(18,'Reliability: Last good DBCC CHECKDB over 2 weeks old','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 1, @CheckID = 68;', 0, 'H')
    ,(19,'Corruption: Database Corruption Detected','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 1, @CheckID = 89;', 0, 'H')
    ,(20,'Corruption: Database Corruption Detected','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 1, @CheckID = 90;', 0, 'H')
    ,(21,'Backup: Backing Up to Same Drive Where Databases Reside','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 1, @CheckID = 93;', 0, 'H')
    ,(22,'Backup: TDE Certificate Not Backed Up Recently','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 1, @CheckID = 119;', 0, 'H')
    ,(23,'Performance: Memory Dangerously Low in NUMA Nodes','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 1, @CheckID = 159;', 0, 'H')
    ,(24,'Backup: Encryption Certificate Not Backed Up Recently','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 1, @CheckID = 202;', 0, 'H')
    ,(25,'Reliability: Priority Boost Enabled','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 5, @CheckID = 126;', 0, 'H')
    ,(26,'Monitoring: Disabled Internal Monitoring Features','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 5, @CheckID = 177;', 0, 'H')
    ,(27,'Reliability: Dangerous Third Party Modules','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 5, @CheckID = 179;', 0, 'H')
    ,(28,'Performance: Auto-Close Enabled','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 10, @CheckID = 12;', 0, 'H')
    ,(29,'Performance: Auto-Shrink Enabled','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 10, @CheckID = 13;', 0, 'H')
    ,(30,'Performance: CPU Schedulers Offline','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 10, @CheckID = 101;', 0, 'H')
    ,(31,'Performance: Memory Nodes Offline','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 10, @CheckID = 110;', 0, 'H')
    ,(32,'Performance: Plan Cache Erased Recently','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 10, @CheckID = 125;', 0, 'H')
    ,(33,'Performance: High Memory Use for In-Memory OLTP (Hekaton)','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 10, @CheckID = 145;', 0, 'H')
    ,(34,'Performance: 32-bit SQL Server Installed','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 10, @CheckID = 154;', 0, 'H')
    ,(35,'Performance: CPU w/Odd Number of Cores','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 10, @CheckID = 198;', 0, 'H')
    ,(36,'Performance: Auto-Shrink Ran Recently','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 10, @CheckID = 206;', 0, 'H')
    ,(37,'Performance: DBCC DROPCLEANBUFFERS Ran Recently','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 10, @CheckID = 207;', 0, 'H')
    ,(38,'Performance: DBCC FREEPROCCACHE Ran Recently','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 10, @CheckID = 208;', 0, 'H')
    ,(39,'Performance: DBCC SHRINK% Ran Recently','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 10, @CheckID = 210;', 0, 'H')
    ,(40,'Reliability: TempDB on C Drive','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 20, @CheckID = 25;', 0, 'H')
    ,(41,'Reliability: User Databases on C Drive','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 20, @CheckID = 26;', 0, 'H')
    ,(42,'Reliability: Databases in Unusual States','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 20, @CheckID = 102;', 0, 'H')
    ,(43,'Reliability: Unsupported Build of SQL Server','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 20, @CheckID = 128;', 0, 'H')
    ,(44,'Reliability: Dangerous Build of SQL Server (Corruption)','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 20, @CheckID = 129;', 0, 'H')
    ,(45,'Reliability: Dangerous Build of SQL Server (Security)','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 20, @CheckID = 157;', 0, 'H')
    ,(46,'Reliability: Plan Guides Failing','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 20, @CheckID = 164;', 0, 'H')
    ,(47,'Reliability: Memory Dumps Have Occurred','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 20, @CheckID = 171;', 0, 'H')
    ,(48,'Reliability: Query Store Cleanup Disabled','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 20, @CheckID = 182;', 0, 'H')
    ,(49,'Reliability: No Failover Cluster Nodes Available','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 20, @CheckID = 184;', 0, 'H')
    ,(50,'Reliability: Page Verification Not Optimal','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 50, @CheckID = 14;', 0, 'H')
    ,(51,'Reliability: Transaction Log Larger than Data File','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 50, @CheckID = 75;', 0, 'H')
    ,(52,'Reliability: Database Snapshot Online','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 50, @CheckID = 77;', 0, 'H')
    ,(53,'Reliability: Remote Admin Connections Disabled','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 50, @CheckID = 100;', 0, 'H')
    ,(54,'Performance: Poison Wait Detected','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 50, @CheckID = 107;', 0, 'H')
    ,(55,'Reliability: Possibly Broken Log Shipping','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 50, @CheckID = 111;', 0, 'H')
    ,(56,'Reliability: Full Text Indexes Not Updating','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 50, @CheckID = 113;', 0, 'H')
    ,(57,'Performance: Poison Wait Detected: Serializable Locking','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 50, @CheckID = 121;', 0, 'H')
    ,(58,'Reliability: Errors Logged Recently in the Default Trace','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 50, @CheckID = 150;', 0, 'H')
    ,(59,'Performance: File Growths Slow','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 50, @CheckID = 151;', 0, 'H')
    ,(60,'Performance: Poison Wait Detected: CMEMTHREAD & NUMA','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 50, @CheckID = 162;', 0, 'H')
    ,(61,'Performance: Too Much Free Memory','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 50, @CheckID = 165;', 0, 'H')
    ,(62,'Reliability: TempDB File Error','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 50, @CheckID = 191;', 0, 'H')
    ,(63,'Performance: Instant File Initialization Not Enabled','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 50, @CheckID = 192;', 0, 'H')
    ,(64,'Reliability: Default Trace File Error','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 50, @CheckID = 199;', 0, 'H')
    ,(65,'DBCC Events: Overall Events','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 50, @CheckID = 203;', 0, 'H')
    ,(66,'Performance: Wait Stats Cleared Recently','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 50, @CheckID = 205;', 0, 'H')
    ,(67,'Reliability: DBCC WRITEPAGE Used Recently','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 50, @CheckID = 209;', 0, 'H')
    ,(68,'Performance: Resource Governor Enabled','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 100, @CheckID = 10;', 0, 'H')
    ,(69,'Performance: Server Triggers Enabled','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 100, @CheckID = 11;', 0, 'H')
    ,(70,'Performance: Single-Use Plans in Procedure Cache','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 100, @CheckID = 35;', 0, 'H')
    ,(71,'Performance: Indexes Disabled','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 100, @CheckID = 47;', 0, 'H')
    ,(72,'Performance: Max Memory Set Too High','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 100, @CheckID = 50;', 0, 'H')
    ,(73,'Performance: Fill Factor Changed','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 100, @CheckID = 60;', 0, 'H')
    ,(74,'Performance: Partitioned database with non-aligned indexes','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 100, @CheckID = 72;', 0, 'H')
    ,(75,'Performance: Stored Procedure WITH RECOMPILE','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 100, @CheckID = 78;', 0, 'H')
    ,(76,'Performance: Shrink Database Job','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 100, @CheckID = 79;', 0, 'H')
    ,(77,'Performance: Unusual SQL Server Edition','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 100, @CheckID = 97;', 0, 'H')
    ,(78,'Performance: Change Tracking Enabled','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 100, @CheckID = 112;', 0, 'H')
    ,(79,'Performance: Memory Pressure Affecting Queries','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 100, @CheckID = 117;', 0, 'H')
    ,(80,'In-Memory OLTP (Hekaton): Transaction Errors','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 100, @CheckID = 147;', 0, 'H')
    ,(81,'Performance: Many Plans for One Query','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 100, @CheckID = 160;', 0, 'H')
    ,(82,'Performance: High Number of Cached Plans','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 100, @CheckID = 161;', 0, 'H')
    ,(83,'Performance: Shrink Database Step In Maintenance Plan','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 100, @CheckID = 180;', 0, 'H')
    ,(84,'Performance: Repetitive Maintenance Tasks','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 100, @CheckID = 181;', 0, 'H')
    ,(85,'Features: Missing Features','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 100, @CheckID = 189;', 0, 'H')
    ,(86,'Performance: Auto-Create Stats Disabled','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 110, @CheckID = 15;', 0, 'H')
    ,(87,'Performance: Auto-Update Stats Disabled','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 110, @CheckID = 16;', 0, 'H')
    ,(88,'Performance: Active Tables Without Clustered Indexes','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 110, @CheckID = 38;', 0, 'H')
    ,(89,'Performance: Plan Guides Enabled','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 110, @CheckID = 95;', 0, 'H')
    ,(90,'Performance: Infinite merge replication metadata retention period','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 110, @CheckID = 99;', 0, 'H')
    ,(91,'Performance: Parallelism Rocket Surgery','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 110, @CheckID = 115;', 0, 'H')
    ,(92,'Query Plans: Implicit Conversion','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 120, @CheckID = 63;', 0, 'H')
    ,(93,'Query Plans: Implicit Conversion Affecting Cardinality','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 120, @CheckID = 64;', 0, 'H')
    ,(94,'Query Plans: Missing Index','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 120, @CheckID = 65;', 0, 'H')
    ,(95,'Query Plans: Cursor','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 120, @CheckID = 66;', 0, 'H')
    ,(96,'Query Plans: Scalar UDFs','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 120, @CheckID = 67;', 0, 'H')
    ,(97,'Query Plans: RID or Key Lookups','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 120, @CheckID = 118;', 0, 'H')
    ,(98,'Performance: Stats Updated Asynchronously','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 150, @CheckID = 17;', 0, 'H')
    ,(99,'Performance: Forced Parameterization On','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 150, @CheckID = 18;', 0, 'H')
    --,(100,'Performance: Triggers on Tables','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 150, @CheckID = 32;', 0, 'H')
    ,(101,'Performance: Slow Storage Reads on Drive','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 150, @CheckID = 36;', 0, 'H')
    ,(102,'Performance: Slow Storage Writes on Drive','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 150, @CheckID = 37;', 0, 'H')
    ,(103,'Performance: Inactive Tables Without Clustered Indexes','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 150, @CheckID = 39;', 0, 'H')
    ,(104,'Performance: Queries Forcing Order Hints','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 150, @CheckID = 44;', 0, 'H')
    ,(105,'Performance: Queries Forcing Join Hints','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 150, @CheckID = 45;', 0, 'H')
    ,(106,'Performance: Leftover Fake Indexes From Wizards','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 150, @CheckID = 46;', 0, 'H')
    ,(107,'Performance: Foreign Keys Not Trusted','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 150, @CheckID = 48;', 0, 'H')
    ,(108,'Performance: Check Constraint Not Trusted','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 150, @CheckID = 56;', 0, 'H')
    ,(109,'Performance: Deadlocks Happening Daily','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 150, @CheckID = 124;', 0, 'H')
    ,(110,'File Configuration: System Database on C Drive','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 170, @CheckID = 24;', 0, 'H')
    ,(111,'File Configuration: TempDB Only Has 1 Data File','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 170, @CheckID = 40;', 0, 'H')
    ,(112,'File Configuration: Multiple Log Files on One Drive','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 170, @CheckID = 41;', 0, 'H')
    ,(113,'File Configuration: Uneven File Growth Settings in One Filegroup','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 170, @CheckID = 42;', 0, 'H')
    ,(114,'File Configuration: High VLF Count','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 170, @CheckID = 69;', 0, 'H')
    ,(115,'Reliability: Max File Size Set','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 170, @CheckID = 80;', 0, 'H')
    ,(116,'File Configuration: File growth set to percent','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 170, @CheckID = 82;', 0, 'H')
    ,(117,'Reliability: Database Files on Network File Shares','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 170, @CheckID = 148;', 0, 'H')
    ,(118,'Reliability: Database Files Stored in Azure','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 170, @CheckID = 149;', 0, 'H')
    ,(119,'File Configuration: File growth set to 1MB','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 170, @CheckID = 158;', 0, 'H')
    ,(120,'File Configuration: TempDB Has >16 Data Files','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 170, @CheckID = 175;', 0, 'H')
    ,(121,'File Configuration: TempDB Unevenly Sized Data Files','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 170, @CheckID = 183;', 0, 'H')
    ,(122,'Backup: MSDB Backup History Not Purged','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 3;', 0, 'H')
    ,(123,'Surface Area: Endpoints Configured','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 9;', 0, 'H')
    ,(124,'Informational: Replication In Use','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 19;', 0, 'H')
    ,(125,'Informational: Date Correlation On','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 20;', 0, 'H')
    ,(126,'Informational: Database Encrypted','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 21;', 0, 'H')
    ,(127,'Informational: Tables in the Master Database','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 27;', 0, 'H')
    ,(128,'Informational: Tables in the MSDB Database','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 28;', 0, 'H')
    ,(129,'Informational: Tables in the Model Database','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 29;', 0, 'H')
    ,(130,'Monitoring: Not All Alerts Configured','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 30;', 0, 'H')
    ,(131,'Monitoring: No Operators Configured/Enabled','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 31;', 0, 'H')
    ,(132,'Licensing: Enterprise Edition Features In Use','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 33;', 0, 'H')
    --,(133,'Informational: Linked Server Configured','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 49;', 0, 'H')
    --,(134,'Informational: Cluster Node','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 53;', 0, 'H')
    ,(135,'Informational: Database Collation Mismatch','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 58;', 0, 'H')
    ,(136,'Monitoring: Alerts Configured without Follow Up','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 59;', 0, 'H')
    ,(137,'Monitoring: No Alerts for Sev 19-25','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 61;', 0, 'H')
    ,(138,'Performance: Old Compatibility Level','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 62;', 0, 'H')
    ,(139,'Informational: @@Servername not set','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 70;', 0, 'H')
    ,(140,'Monitoring: No failsafe operator configured','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 73;', 0, 'H')
    --,(141,'Informational: TraceFlag On','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 74;', 0, 'H')
    --,(142,'Informational: Collation different than tempdb','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 76;', 0, 'H')
    ,(143,'Non-Active Server Config: Config Not Running at Set Value','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 81;', 0, 'H')
    ,(144,'Monitoring: Agent Jobs Without Failure Emails','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 94;', 0, 'H')
    ,(145,'Monitoring: No Alerts for Corruption','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 96;', 0, 'H')
    ,(146,'Monitoring: Alerts Disabled','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 98;', 0, 'H')
    ,(147,'Reliability: Extended Stored Procedures in Master','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 105;', 0, 'H')
    ,(148,'Informational: Backup Compression Default Off','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 116;', 0, 'H')
    ,(149,'Performance: User-Created Statistics In Place','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 122;', 0, 'H')
    ,(150,'Informational: Agent Jobs Starting Simultaneously','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 123;', 0, 'H')
    ,(151,'Backup: Backing Up Unneeded Database','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 127;', 0, 'H')
    ,(152,'Performance: In-Memory OLTP (Hekaton) In Use','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 146;', 0, 'H')
    ,(153,'Performance: Query Store Disabled','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 163;', 0, 'H')
    ,(154,'Licensing: Non-Production License','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 173;', 0, 'H')
    ,(155,'Performance: Buffer Pool Extensions Enabled','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 174;', 0, 'H')
    ,(156,'Monitoring: Extended Events Hyperextension','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 176;', 0, 'H')
    ,(157,'Performance: Snapshot Backups Occurring','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 178;', 0, 'H')
    ,(158,'Backup: MSDB Backup History Purged Too Frequently','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 186;', 0, 'H')
    ,(159,'Performance: Default Parallelism Settings','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 188;', 0, 'H')
    ,(160,'Performance: Non-Dynamic Memory','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 190;', 0, 'H')
    ,(161,'Non-Default Server Config: access check cache bucket count','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 1001;', 0, 'H')
    ,(162,'Non-Default Server Config: access check cache quota','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 1002;', 0, 'H')
    ,(163,'Non-Default Server Config: Ad Hoc Distributed Queries','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 1003;', 0, 'H')
    ,(164,'Non-Default Server Config: affinity I/O mask','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 1004;', 0, 'H')
    ,(165,'Non-Default Server Config: affinity mask','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 1005;', 0, 'H')
    ,(166,'Non-Default Server Config: allow updates','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 1007;', 0, 'H')
    ,(167,'Non-Default Server Config: awe enabled','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 1008;', 0, 'H')
    ,(168,'Non-Default Server Config: blocked process threshold','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 1009;', 0, 'H')
    ,(169,'Non-Default Server Config: c2 audit mode','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 1010;', 0, 'H')
    ,(170,'Non-Default Server Config: clr enabled','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 1011;', 0, 'H')
    ,(171,'Non-Default Server Config: cost threshold for parallelism','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 1012;', 0, 'H')
    ,(172,'Non-Default Server Config: cross db ownership chaining','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 1013;', 0, 'H')
    ,(173,'Non-Default Server Config: cursor threshold','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 1014;', 0, 'H')
    ,(174,'Non-Default Server Config: default full-text language','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 1016;', 0, 'H')
    ,(175,'Non-Default Server Config: default language','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 1017;', 0, 'H')
    ,(176,'Non-Default Server Config: default trace enabled','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 1018;', 0, 'H')
    ,(177,'Non-Default Server Config: disallow results from triggers','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 1019;', 0, 'H')
    ,(178,'Non-Default Server Config: fill factor (%)','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 1020;', 0, 'H')
    ,(179,'Non-Default Server Config: ft crawl bandwidth (max)','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 1021;', 0, 'H')
    ,(180,'Non-Default Server Config: ft crawl bandwidth (min)','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 1022;', 0, 'H')
    ,(181,'Non-Default Server Config: ft notify bandwidth (max)','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 1023;', 0, 'H')
    ,(182,'Non-Default Server Config: ft notify bandwidth (min)','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 1024;', 0, 'H')
    ,(183,'Non-Default Server Config: index create memory (KB)','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 1025;', 0, 'H')
    ,(184,'Non-Default Server Config: in-doubt xact resolution','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 1026;', 0, 'H')
    ,(185,'Non-Default Server Config: lightweight pooling','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 1027;', 0, 'H')
    ,(186,'Non-Default Server Config: locks','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 1028;', 0, 'H')
    ,(187,'Non-Default Server Config: max degree of parallelism','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 1029;', 0, 'H')
    ,(188,'Non-Default Server Config: max full-text crawl range','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 1030;', 0, 'H')
    ,(189,'Non-Default Server Config: max server memory (MB)','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 1031;', 0, 'H')
    ,(190,'Non-Default Server Config: max text repl size (B)','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 1032;', 0, 'H')
    ,(191,'Non-Default Server Config: max worker threads','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 1033;', 0, 'H')
    ,(192,'Non-Default Server Config: media retention','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 1034;', 0, 'H')
    ,(193,'Non-Default Server Config: min memory per query (KB)','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 1035;', 0, 'H')
    ,(194,'Non-Default Server Config: min server memory (MB)','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 1036;', 0, 'H')
    ,(195,'Non-Default Server Config: nested triggers','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 1037;', 0, 'H')
    ,(196,'Non-Default Server Config: network packet size (B)','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 1038;', 0, 'H')
    ,(197,'Non-Default Server Config: Ole Automation Procedures','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 1039;', 0, 'H')
    ,(198,'Non-Default Server Config: open objects','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 1040;', 0, 'H')
    ,(199,'Non-Default Server Config: optimize for ad hoc workloads','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 1041;', 0, 'H')
    ,(200,'Non-Default Server Config: PH timeout (s)','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 1042;', 0, 'H')
    ,(201,'Non-Default Server Config: precompute rank','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 1043;', 0, 'H')
    ,(202,'Non-Default Server Config: priority boost','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 1044;', 0, 'H')
    ,(203,'Non-Default Server Config: query governor cost limit','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 1045;', 0, 'H')
    ,(204,'Non-Default Server Config: query wait (s)','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 1046;', 0, 'H')
    ,(205,'Non-Default Server Config: recovery interval (min)','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 1047;', 0, 'H')
    ,(206,'Non-Default Server Config: remote access','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 1048;', 0, 'H')
    ,(207,'Non-Default Server Config: remote admin connections','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 1049;', 0, 'H')
    ,(208,'Non-Default Server Config: remote proc trans','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 1050;', 0, 'H')
    ,(209,'Non-Default Server Config: remote query timeout (s)','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 1051;', 0, 'H')
    ,(210,'Non-Default Server Config: Replication XPs','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 1052;', 0, 'H')
    ,(211,'Non-Default Server Config: RPC parameter data validation','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 1053;', 0, 'H')
    ,(212,'Non-Default Server Config: scan for startup procs','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 1054;', 0, 'H')
    ,(213,'Non-Default Server Config: server trigger recursion','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 1055;', 0, 'H')
    ,(214,'Non-Default Server Config: set working set size','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 1056;', 0, 'H')
    ,(215,'Non-Default Server Config: show advanced options','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 1057;', 0, 'H')
    ,(216,'Non-Default Server Config: SMO and DMO XPs','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 1058;', 0, 'H')
    ,(217,'Non-Default Server Config: SQL Mail XPs','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 1059;', 0, 'H')
    ,(218,'Non-Default Server Config: transform noise words','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 1060;', 0, 'H')
    ,(219,'Non-Default Server Config: two digit year cutoff','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 1061;', 0, 'H')
    ,(220,'Non-Default Server Config: user connections','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 1062;', 0, 'H')
    ,(221,'Non-Default Server Config: user options','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 1063;', 0, 'H')
    ,(222,'Non-Default Server Config: Web Assistant Procedures','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 1064;', 0, 'H')
    ,(223,'Non-Default Server Config: xp_cmdshell','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 1065;', 0, 'H')
    ,(224,'Non-Default Server Config: affinity64 mask','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 1066;', 0, 'H')
    ,(225,'Non-Default Server Config: affinity64 I/O mask','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 1067;', 0, 'H')
    ,(226,'Non-Default Server Config: contained database authentication','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 1068;', 0, 'H')
    ,(227,'Non-Default Server Config: remote login timeout (s)','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 1069;', 0, 'H')
    ,(228,'Non-Default Server Config: backup checksum default','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 1070;', 0, 'H')
    ,(229,'Non-Default Server Config: Agent XPs','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 1071;', 0, 'H')
    ,(230,'Non-Default Server Config: Database Mail XPs','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 1072;', 0, 'H')
    ,(231,'Non-Default Server Config: backup compression default','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 1073;', 0, 'H')
    ,(232,'Non-Default Server Config: common criteria compliance enabled','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 1074;', 0, 'H')
    ,(233,'Non-Default Server Config: EKM provider enabled','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 1075;', 0, 'H')
    ,(234,'Non-Default Server Config: filestream access level','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 200, @CheckID = 1076;', 0, 'H')
    ,(235,'Non-Default Database Config: Supplemental Logging Enabled','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 210, @CheckID = 131;', 0, 'H')
    ,(236,'Non-Default Database Config: Snapshot Isolation Enabled','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 210, @CheckID = 132;', 0, 'H')
    ,(237,'Non-Default Database Config: Read Committed Snapshot Isolation Enabled','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 210, @CheckID = 133;', 0, 'H')
    ,(238,'Non-Default Database Config: Auto Create Stats Incremental Enabled','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 210, @CheckID = 134;', 0, 'H')
    ,(239,'Non-Default Database Config: ANSI NULL Default Enabled','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 210, @CheckID = 135;', 0, 'H')
    ,(240,'Non-Default Database Config: Recursive Triggers Enabled','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 210, @CheckID = 136;', 0, 'H')
    ,(241,'Non-Default Database Config: Trustworthy Enabled','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 210, @CheckID = 137;', 0, 'H')
    ,(242,'Non-Default Database Config: Forced Parameterization Enabled','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 210, @CheckID = 138;', 0, 'H')
    ,(243,'Non-Default Database Config: Query Store Enabled','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 210, @CheckID = 139;', 0, 'H')
    ,(244,'Non-Default Database Config: Change Data Capture Enabled','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 210, @CheckID = 140;', 0, 'H')
    ,(245,'Non-Default Database Config: Containment Enabled','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 210, @CheckID = 141;', 0, 'H')
    ,(246,'Non-Default Database Config: Target Recovery Time Changed','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 210, @CheckID = 142;', 0, 'H')
    ,(247,'Non-Default Database Config: Delayed Durability Enabled','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 210, @CheckID = 143;', 0, 'H')
    ,(248,'Non-Default Database Config: Memory Optimized Enabled','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 210, @CheckID = 144;', 0, 'H')
    ,(249,'Non-Default Database Scoped Config: MAXDOP','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 210, @CheckID = 194;', 0, 'H')
    ,(250,'Non-Default Database Scoped Config: Legacy CE','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 210, @CheckID = 195;', 0, 'H')
    ,(251,'Non-Default Database Scoped Config: Parameter Sniffing','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 210, @CheckID = 196;', 0, 'H')
    ,(252,'Non-Default Database Scoped Config: Query Optimizer Hotfixes','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 210, @CheckID = 197;', 0, 'H')
    ,(253,'Security: Sysadmins','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 230, @CheckID = 4;', 0, 'H')
    ,(254,'Security: Security Admins','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 230, @CheckID = 5;', 0, 'H')
    ,(255,'Security: Jobs Owned By Users','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 230, @CheckID = 6;', 0, 'H')
    ,(256,'Security: Stored Procedure Runs at Startup','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 230, @CheckID = 7;', 0, 'H')
    ,(257,'Security: Server Audits Running','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 230, @CheckID = 8;', 0, 'H')
    ,(258,'Security: Database Owner <> SA','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 230, @CheckID = 55;', 0, 'H')
    ,(259,'Security: SQL Agent Job Runs at Startup','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 230, @CheckID = 57;', 0, 'H')
    ,(260,'Security: Elevated Permissions on a Database','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 230, @CheckID = 86;', 0, 'H')
    ,(261,'Security: Control Server Permissions','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 230, @CheckID = 104;', 0, 'H')
    ,(262,'Security: Endpoints Owned by Users','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 230, @CheckID = 187;', 0, 'H')
    ,(263,'Wait Stats: Top Wait Stats','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 240, @CheckID = 152;', 0, 'H')
    --,(264,'Wait Stats: No Significant Waits Detected','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 240, @CheckID = 153;', 0, 'H')
    ,(265,'Wait Stats: Wait Stats Have Been Cleared','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 240, @CheckID = 185;', 0, 'H')
    --,(266,'Server Info: Services','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 250, @CheckID = 83;', 0, 'H')
    --,(267,'Server Info: Hardware','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 250, @CheckID = 84;', 0, 'H')
    --,(268,'Server Info: SQL Server Service','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 250, @CheckID = 85;', 0, 'H')
    ,(269,'Server Info: SQL Server Last Restart','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 250, @CheckID = 88;', 0, 'H')
    ,(270,'Server Info: Server Last Restart','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 250, @CheckID = 91;', 0, 'H')
    --,(271,'Server Info: Drive Space','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 250, @CheckID = 92;', 0, 'H')
    --,(272,'Server Info: Virtual Server','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 250, @CheckID = 103;', 0, 'H')
    --,(273,'Server Info: Default Trace Contents','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 250, @CheckID = 106;', 0, 'H')
    --,(274,'Server Info: Hardware - NUMA Config','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 250, @CheckID = 114;', 0, 'H')
    --,(275,'Server Info: Server Name','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 250, @CheckID = 130;', 0, 'H')
    ,(276,'Server Info: Locked Pages in Memory Enabled','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 250, @CheckID = 166;', 0, 'H')
    ,(277,'Server Info: Agent is Currently Offline','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 250, @CheckID = 167;', 0, 'H')
    ,(278,'Server Info: Full-text Filter Daemon is Currently Offline','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 250, @CheckID = 168;', 0, 'H')
    ,(279,'Informational: SQL Server is running under an NT Service account','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 250, @CheckID = 169;', 0, 'H')
    ,(280,'Informational: SQL Server Agent is running under an NT Service account','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 250, @CheckID = 170;', 0, 'H')
    ,(281,'Server Info: Windows Version','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 250, @CheckID = 172;', 0, 'H')
    --,(282,'Server Info: Instant File Initialization Enabled','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 250, @CheckID = 193;', 0, 'H')
    ,(283,'Server Info: Power Plan','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 250, @CheckID = 211;', 0, 'H')
    ,(284,'Server Info: Stacked Instances','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 250, @CheckID = 212;', 0, 'H')
    --,(285,'Rundate: (Current Date)','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 254, @CheckID = 156;', 0, 'H')
    --,(286,'Thanks!: From Your Community Volunteers','Custom Monthly',1,'','EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 255, @CheckID = -1;', 0, 'H')
GO
SET IDENTITY_INSERT [dbo].[Reports] OFF
GO
-- END: sp_Blitz reports

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
EXEC [Reporting].[uspFailedServerAgentJobs] @ServerName = 'SRVR02';
EXEC [Reporting].[uspListServerFreeSpaceTrend] @ServerName='SRVR01';
EXEC [Reporting].[uspListDatabaseGrowthTrend] @ServerName='SRVR01', @DatabaseName='AdventureWorks';
EXEC [Reporting].[uspListFailedLogins] @ServerName='SRVR01';
EXEC [Reporting].[uspListServerLogins] @ServerName='SRVR01', @RoleName='sysadmin';
*/

-- SELECT * FROM [dbo].[Reports] ORDER BY [ReportID]
/* -------------------------------------------------- */


/* ----- dbo.ReportRecipients ----- */
/*
-- NOTE: Watch out for single quotes in the PreExecuteScript and ExecuteScript columns
SELECT 
    ',(''' + ReportName + ''',''' + ReportType + ''',''' + CAST(ExecutionOrder AS varchar(10)) + ''',''' + 
    COALESCE(PreExecuteScript, '') + ''',''' + COALESCE(ExecuteScript, '') + ''')'
FROM [SQLMonitor].[dbo].[ReportRecipients]
ORDER BY ReportType, ExecutionOrder, ReportName
*/

-- TRUNCATE TABLE [dbo].[ReportRecipients];
INSERT INTO [dbo].[ReportRecipients] (
    [RecipientName], [RecipientEmailAddress], [SendingOrder], [RecordStatus]
    )
VALUES
     ('DBA Team',      'dba.team@mycompany.com',      1, 'A')
    ,('Jason Bourne',  'jason.bourne@mycompany.com',  1, 'A')
    ,('Mary Poppins',  'mary.poppins@mycompany.com',  1, 'A')
    ,('William Tell',  'william.tell@mycompany.com',  1, 'A')
    ,('Bud Spencer',   'bud.spencer@mycompany.com',   1, 'A')
    ,('Clark Kent',    'clark.kent@mycompany.com',    1, 'A')
    ,('Ugo Fantozzi',  'ugo.fantozzi@mycompany.com',  1, 'A')
    ,('Service Desk',  'servicedesk@mycompany.com',   1, 'H')
GO

/*
-- Test Check Constraint:
INSERT INTO [dbo].[ReportRecipients] ([RecipientName], [RecipientEmailAddress], [SendingOrder], [RecordStatus])
VALUES ('Reuben Sultana GMAIL', 'reuben.sultana@gmail.com', 1, 'A');
*/

-- SELECT * FROM [dbo].[ReportRecipients] ORDER BY [ReportRecipientID]
/* -------------------------------------------------- */


/* ----- dbo.ReportSubscriptions ----- */

-- TRUNCATE TABLE [dbo].[ReportSubscriptions]
INSERT INTO [dbo].[ReportSubscriptions] ([ReportRecipient], [ReportID], [RecordStatus], [RecordCreated])
VALUES 
     (1, NULL, 'A', CURRENT_TIMESTAMP) 
    ,(2, NULL, 'A', CURRENT_TIMESTAMP)
    ,(3, 3, 'A', CURRENT_TIMESTAMP)
    ,(4, 6, 'A', CURRENT_TIMESTAMP)
    ,(4, 8, 'A', CURRENT_TIMESTAMP)
    ,(5, 5, 'A', CURRENT_TIMESTAMP)
    ,(5, 7, 'A', CURRENT_TIMESTAMP)
    ,(6, 6, 'A', CURRENT_TIMESTAMP)
    ,(6, 8, 'A', CURRENT_TIMESTAMP)
    ,(7, 10, 'A', CURRENT_TIMESTAMP)  
    ,(1, 7, 'A', CURRENT_TIMESTAMP)   
    ,(1, 8, 'A', CURRENT_TIMESTAMP)   
    ,(1, 9, 'A', CURRENT_TIMESTAMP)   
GO
INSERT INTO [dbo].[ReportSubscriptions] ([ReportRecipient], [ReportID], [RecordStatus], [RecordCreated])
VALUES 
     (8, 14, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 15, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 16, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 17, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 18, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 19, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 20, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 21, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 22, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 23, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 24, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 25, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 26, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 27, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 28, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 29, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 30, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 31, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 32, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 33, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 34, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 35, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 36, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 37, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 38, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 39, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 40, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 41, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 42, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 43, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 44, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 45, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 46, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 47, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 48, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 49, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 50, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 51, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 52, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 53, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 54, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 55, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 56, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 57, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 58, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 59, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 60, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 61, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 62, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 63, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 64, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 65, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 66, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 67, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 68, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 69, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 70, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 71, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 72, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 73, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 74, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 75, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 76, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 77, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 78, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 79, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 80, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 81, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 82, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 83, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 84, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 85, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 86, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 87, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 88, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 89, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 90, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 91, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 92, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 93, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 94, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 95, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 96, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 97, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 98, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 99, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 101, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 102, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 103, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 104, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 105, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 106, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 107, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 108, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 109, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 110, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 111, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 112, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 113, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 114, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 115, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 116, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 117, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 118, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 119, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 120, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 121, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 122, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 123, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 124, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 125, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 126, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 127, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 128, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 129, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 130, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 131, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 132, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 135, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 136, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 137, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 138, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 139, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 140, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 143, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 144, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 145, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 146, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 147, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 148, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 149, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 150, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 151, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 152, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 153, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 154, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 155, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 156, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 157, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 158, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 159, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 160, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 161, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 162, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 163, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 164, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 165, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 166, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 167, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 168, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 169, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 170, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 171, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 172, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 173, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 174, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 175, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 176, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 177, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 178, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 179, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 180, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 181, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 182, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 183, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 184, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 185, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 186, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 187, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 188, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 189, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 190, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 191, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 192, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 193, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 194, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 195, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 196, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 197, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 198, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 199, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 200, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 201, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 202, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 203, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 204, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 205, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 206, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 207, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 208, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 209, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 210, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 211, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 212, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 213, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 214, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 215, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 216, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 217, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 218, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 219, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 220, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 221, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 222, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 223, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 224, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 225, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 226, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 227, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 228, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 229, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 230, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 231, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 232, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 233, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 234, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 235, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 236, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 237, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 238, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 239, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 240, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 241, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 242, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 243, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 244, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 245, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 246, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 247, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 248, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 249, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 250, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 251, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 252, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 253, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 254, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 255, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 256, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 257, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 258, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 259, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 260, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 261, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 262, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 263, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 265, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 269, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 270, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 276, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 277, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 278, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 279, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 280, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 281, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 283, 'H', CURRENT_TIMESTAMP)  -- Service Desk
    ,(8, 284, 'H', CURRENT_TIMESTAMP)  -- Service Desk
GO

/* -------------------------------------------------- */


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
	('SQLServer_BuildVersion_2005',	'9.00.5324.0', 'Latest build version for SQL Server 2005', 'A', CURRENT_TIMESTAMP),
	('SQLServer_BuildVersion_2008', '10.00.6547.0', 'Latest build version for SQL Server 2008', 'A', CURRENT_TIMESTAMP),
	('SQLServer_BuildVersion_2008R2', '10.50.6529.0', 'Latest build version for SQL Server 2008 R2', 'A', CURRENT_TIMESTAMP),
	('SQLServer_BuildVersion_2012', '11.0.7001.0', 'Latest build version for SQL Server 2012',	'A', CURRENT_TIMESTAMP),
	('SQLServer_BuildVersion_2014', '12.0.5557.0', 'Latest build version for SQL Server 2014',	'A', CURRENT_TIMESTAMP),
	('SQLServer_BuildVersion_2016', '13.0.4457.0', 'Latest build version for SQL Server 2016',	'A', CURRENT_TIMESTAMP),
    ('SQLServer_BuildVersion_2017', '14.0.3008.27', 'Latest build version for SQL Server 2017',	'A', CURRENT_TIMESTAMP)
GO

-- SELECT * FROM [dbo].[SystemParams] ORDER BY [ParamName]
/* -------------------------------------------------- */


USE [master]
GO
