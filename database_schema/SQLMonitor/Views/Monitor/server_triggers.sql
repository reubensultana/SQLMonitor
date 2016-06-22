USE [SQLMonitor]
GO

IF OBJECT_ID('[Monitor].[server_triggers]') IS NOT NULL
DROP VIEW [Monitor].[server_triggers]
GO

CREATE VIEW [Monitor].[server_triggers]
AS
SELECT [ServerName]
    ,[ObjectName]
    ,[ObjectType]
    ,[CreateDate]
    ,[ModifyDate]
    ,[IsDisabled]
    ,[RecordStatus]
    ,[RecordCreated]
FROM [Monitor].[ServerTriggers]
--WHERE [RecordStatus] = 'A'
GO
