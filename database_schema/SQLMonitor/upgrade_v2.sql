USE [SQLMonitor]
GO
SET NOCOUNT ON;

-- Schema name used for Staging purposes
INSERT INTO [dbo].[SystemParams] (
    [ParamName], [ParamValue], [ParamDescription], [RecordStatus], [RecordCreated])
VALUES 
    ('SchemaName_Staging', 'Staging', 'Schema name used for Staging purposes', 'A', DEFAULT);
GO

-- changes to script file names
UPDATE [dbo].[Profile] SET [ScriptName] = n.[NewScriptName]
FROM [dbo].[Profile] p
    INNER JOIN (
        SELECT 'Monitor' AS [ProfileName], 'blitz_results' AS [ScriptName], 'BlitzResults' AS [NewScriptName] UNION ALL
        SELECT 'Monitor', 'database_backup_history', 'DatabaseBackupHistory' UNION ALL
        SELECT 'Monitor', 'database_configurations', 'DatabaseConfigurations' UNION ALL
        SELECT 'Monitor', 'database_table_columns', 'DatabaseTableColumns' UNION ALL
        SELECT 'Monitor', 'database_tables', 'DatabaseTables' UNION ALL
        SELECT 'Monitor', 'database_users', 'DatabaseUsers' UNION ALL
        SELECT 'Monitor', 'database_indexusagestats', 'DatabaseIndexUsageStats' UNION ALL
        SELECT 'Monitor', 'database_missingindexstats', 'DatabaseMissingIndexStats' UNION ALL
        SELECT 'Monitor', 'server_agentconfig', 'ServerAgentConfig' UNION ALL
        SELECT 'Monitor', 'server_agentjobs', 'ServerAgentJobs' UNION ALL
        SELECT 'Monitor', 'server_agentjobshistory', 'ServerAgentJobsHistory' UNION ALL
        SELECT 'Monitor', 'server_configurations', 'ServerConfigurations' UNION ALL
        SELECT 'Monitor', 'server_databases', 'ServerDatabases' UNION ALL
        SELECT 'Monitor', 'server_endpoints', 'ServerEndpoints' UNION ALL
        SELECT 'Monitor', 'server_errorlog', 'ServerErrorLog' UNION ALL
        SELECT 'Monitor', 'server_freespace', 'ServerFreeSpace' UNION ALL
        SELECT 'Monitor', 'server_info', 'ServerInfo' UNION ALL
        SELECT 'Monitor', 'server_logins', 'ServerLogins' UNION ALL
        SELECT 'Monitor', 'server_servers', 'ServerServers' UNION ALL
        SELECT 'Monitor', 'server_triggers', 'ServerTriggers'
    ) n ON p.[ProfileName] = n.[ProfileName] AND p.[ScriptName] = n.[ScriptName]
GO

-- VIEW objects replaced by Staging Tables
DROP VIEW [Monitor].[blitz_results];
DROP VIEW [Monitor].[database_backup_history];
DROP VIEW [Monitor].[database_configurations];
DROP VIEW [Monitor].[database_indexusagestats];
DROP VIEW [Monitor].[database_missingindexstats];
DROP VIEW [Monitor].[database_table_columns];
DROP VIEW [Monitor].[database_tables];
DROP VIEW [Monitor].[database_users];
DROP VIEW [Monitor].[server_agentconfig];
DROP VIEW [Monitor].[server_agentjobs];
DROP VIEW [Monitor].[server_agentjobshistory];
DROP VIEW [Monitor].[server_configurations];
DROP VIEW [Monitor].[server_databases];
DROP VIEW [Monitor].[server_endpoints];
DROP VIEW [Monitor].[server_errorlog];
DROP VIEW [Monitor].[server_freespace];
DROP VIEW [Monitor].[server_info];
DROP VIEW [Monitor].[server_logins];
DROP VIEW [Monitor].[server_servers];
DROP VIEW [Monitor].[server_triggers];
GO

-- rename files (only if the new ones haven't been downloaded them from the Repo)
/*
ren blitz_results.sql BlitzResults.sql
ren database_backup_history.sql DatabaseBackupHistory.sql
ren database_configurations.sql DatabaseConfigurations.sql
ren database_table_columns.sql DatabaseTableColumns.sql
ren database_tables.sql DatabaseTables.sql
ren database_users.sql DatabaseUsers.sql
ren database_indexusagestats.sql DatabaseIndexUsageStats.sql
ren database_missingindexstats.sql DatabaseMissingIndexStats.sql
ren server_agentconfig.sql ServerAgentConfig.sql
ren server_agentjobs.sql ServerAgentJobs.sql
ren server_agentjobshistory.sql ServerAgentJobsHistory.sql
ren server_configurations.sql ServerConfigurations.sql
ren server_databases.sql ServerDatabases.sql
ren server_endpoints.sql ServerEndpoints.sql
ren server_errorlog.sql ServerErrorLog.sql
ren server_freespace.sql ServerFreeSpace.sql
ren server_info.sql ServerInfo.sql
ren server_logins.sql ServerLogins.sql
ren server_servers.sql ServerServers.sql
ren server_triggers.sql ServerTriggers.sql
*/


/* 
BREAKING CHANGES
- modified the RecordCreated column in all Archive, Monitor and Staging tables from dattetime2(0) to datetimeoffset(7). This will allow storing date and time values in UTC values, with a nanosecond precision.
  See: https://docs.microsoft.com/en-us/sql/t-sql/data-types/datetimeoffset-transact-sql
- modified the DEFAULT CONSTRAINT for the RecordCreated column from CURRENT_TIMESTAMP to SYSDATETIMEOFFSET()
  See: https://docs.microsoft.com/en-us/sql/t-sql/functions/sysdatetimeoffset-transact-sql

*/
