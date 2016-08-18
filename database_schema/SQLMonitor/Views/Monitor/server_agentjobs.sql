USE [SQLMonitor]
GO

IF OBJECT_ID('[Monitor].[server_agentjobs]') IS NOT NULL
DROP VIEW [Monitor].[server_agentjobs]
GO

CREATE VIEW [Monitor].[server_agentjobs]
AS
SELECT [ServerName]
    ,[JobID] 
    ,[JobName] 
    ,[Enabled] 
    ,[JobOwner] 
    ,[LastRunDateTime] 
    ,[LastRunStatus] 
    ,[LastRunDuration] 
    ,[NextRunDateTime] 
    ,[LastInvokedBy] 
    ,[Cancelled\StoppedBy] 
    ,[Message] 
    ,[RecordStatus]
    ,[RecordCreated]
FROM [Monitor].[ServerAgentJobs]
--WHERE [RecordStatus] = 'A'
GO
