/* ----- dbo.Profile ----- */
/*
-- NOTE: Watch out for single quotes in the PreExecuteScript and ExecuteScript columns
SELECT 
    ',(''' + ProfileName + ''',''' + ScriptName + ''',''' + CAST(ExecutionOrder AS varchar(10)) + ''',''' + ProfileType + ''',''' + 
    COALESCE(REPLACE(PreExecuteScript, '''', ''''''), '') + ''',''' + COALESCE(REPLACE(ExecuteScript, '''', ''''''), '') + ''')'
FROM [SQLMonitor].[dbo].[Profile]
ORDER BY ProfileType, ExecutionOrder, ProfileName, ScriptName
*/

-- NOTE 1: Every PreExecuteScript command MUST have a single filtering "@ServerName" parameter:
-- NOTE 2: Every PreExecuteScript command MUST always return a single datetime value cast as a VARCHAR(25) data type, with the column name being "Output"
-- ---------------------------------------------
-- TRUNCATE TABLE [dbo].[Profile];
INSERT INTO [dbo].[Profile] (
    ProfileName, ScriptName, ExecutionOrder, ProfileType, PreExecuteScript, ExecuteScript )
VALUES
    ('Monitor','ServerAgentJobs','1','Daily','','')
    ,('Monitor','DatabaseBackupHistory','2','Daily','SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED; SELECT COALESCE(CONVERT(varchar(25), MAX([StartDate]), 121), (CONVERT(varchar(7), DATEADD(month, -3, SYSDATETIMEOFFSET()), 121)+''-01'')) AS [Output] FROM [Monitor].[DatabaseBackupHistory] WHERE [ServerName] = @ServerName AND [RecordStatus] = ''A'';','')
    ,('Monitor','DatabaseIndexUsageStats','3','Daily','TRUNCATE TABLE [Staging].[DatabaseIndexUsageStats];','')
    ,('Monitor','DatabaseMissingIndexStats','4','Daily','TRUNCATE TABLE [Staging].[DatabaseMissingIndexStats];','')
    
    ,('Monitor','ServerErrorLog','1','Hourly','SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED; SELECT COALESCE(CONVERT(varchar(25), MAX([LogDate]), 121), ''1753-01-01 00:00:00'') AS [Output] FROM [Monitor].[ServerErrorLog] WHERE [ServerName] = @ServerName;','')
    
    ,('Monitor','BlitzResults','0','Manual','DELETE FROM [Monitor].[BlitzResults] WHERE [ServerName] = @ServerName;','')
    
    ,('Monitor','ServerAgentJobsHistory','1','Minute','SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED; SELECT COALESCE(CONVERT(varchar(25), MAX([LastRunTime]), 121), ''1753-01-01 00:00:00'') AS [Output] FROM [Monitor].[ServerAgentJobsHistory] WHERE [ServerName] = @ServerName AND [RecordStatus] = ''A'';','')
    
    ,('Monitor','ServerInfo','1','Monthly','','')
    ,('Monitor','ServerLogins','2','Monthly','','')
    ,('Monitor','ServerDatabases','3','Monthly','','')
    ,('Monitor','ServerConfigurations','4','Monthly','','')
    ,('Monitor','ServerServers','5','Monthly','','')
    ,('Monitor','ServerTriggers','6','Monthly','','')
    ,('Monitor','ServerEndpoints','7','Monthly','','')
    ,('Monitor','ServerAgentConfig','8','Monthly','','')
    ,('Monitor','DatabaseTableColumns','9','Monthly','DELETE FROM [Monitor].[DatabaseTableColumns] WHERE [ServerName] = @ServerName;','')
    ,('Monitor','ServerMSB','10','Monthly','','')

    ,('Monitor','DatabaseConfigurations','1','Weekly','','')
    ,('Monitor','DatabaseUsers','2','Weekly','','')
    ,('Monitor','DatabaseTables','3','Weekly','','')
    ,('Monitor','ServerFreeSpace','4','Weekly','','')
GO

-- SELECT * FROM [dbo].[Profile]
