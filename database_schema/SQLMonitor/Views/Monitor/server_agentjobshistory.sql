USE [SQLMonitor]
GO

IF OBJECT_ID('[Monitor].[server_agentjobshistory]') IS NOT NULL
DROP VIEW [Monitor].[server_agentjobshistory]
GO

CREATE VIEW [Monitor].[server_agentjobshistory]
AS
SELECT [ServerName]
    ,[JobID]
    ,[JobName]
    ,[StepID]
    ,[StepName]
    ,[LastRunTime]
    ,[RunStatus]
    ,[Message]
    ,[RecordStatus]
    ,[RecordCreated]
FROM [Monitor].[ServerAgentJobsHistory]
--WHERE [RecordStatus] = 'A'
GO
