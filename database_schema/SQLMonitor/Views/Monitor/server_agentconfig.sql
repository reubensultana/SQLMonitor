USE [SQLMonitor]
GO

IF OBJECT_ID('[Monitor].[server_agentconfig]') IS NOT NULL
DROP VIEW [Monitor].[server_agentconfig]
GO

CREATE VIEW [Monitor].[server_agentconfig]
AS
SELECT [ServerName]
    ,[AutoStart]
    ,[StartupAccount]
    ,[JobHistoryMaxRows]
    ,[JobHistoryMaxRowsPerJob]
    ,[ErrorLogFile]
    ,[EmailProfile]
    ,[FailSafeOperator]
    ,[RecordStatus]
    ,[RecordCreated]
FROM [Monitor].[ServerAgentConfig]
--WHERE [RecordStatus] = 'A'
GO
