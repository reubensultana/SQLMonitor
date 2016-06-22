USE [SQLMonitor]
GO

IF OBJECT_ID('[Monitor].[server_errorlog]') IS NOT NULL
DROP VIEW [Monitor].[server_errorlog]
GO

CREATE VIEW [Monitor].[server_errorlog]
AS
SELECT [ServerName]
    ,[LogDate]
    ,[ProcessInfo]
    ,[LogText]
    ,[RecordStatus]
    ,[RecordCreated]
FROM [Monitor].[ServerErrorLog]
--WHERE [RecordStatus] = 'A'
GO
