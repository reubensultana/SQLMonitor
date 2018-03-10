USE [SQLMonitor]
GO

IF OBJECT_ID('[Monitor].[blitz_results]') IS NOT NULL
DROP VIEW [Monitor].[blitz_results]
GO

CREATE VIEW [Monitor].[blitz_results]
AS
SELECT 
    [ServerName]
    ,[Priority]
    ,[FindingsGroup]
    ,[Finding]
    ,[DatabaseName]
    ,[URL]
    ,[Details]
    ,[QueryPlan]
    ,[QueryPlanFiltered]
    ,[CheckID]
    ,[RecordStatus]
    ,[RecordCreated]
FROM [Monitor].[BlitzResults]
GO
