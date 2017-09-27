USE [SQLMonitor]
GO

IF OBJECT_ID('[dbo].[vwProfile]') IS NOT NULL
DROP VIEW [dbo].[vwProfile]
GO

CREATE VIEW [dbo].[vwProfile]
AS
SELECT
    p.[ProfileType], p.[ProfileName], 
    p.[ScriptName], p.[PreExecuteScript], p.[ExecuteScript], 
    -- an integer indicating the number of minutes that should elapse between iterations
    CASE p.[ProfileType]
        WHEN 'Annual'   THEN DATEDIFF(N, DATEADD(YY, -1, CURRENT_TIMESTAMP), CURRENT_TIMESTAMP)
        WHEN 'Monthly'  THEN DATEDIFF(N, DATEADD(MM, -1, CURRENT_TIMESTAMP), CURRENT_TIMESTAMP)
        WHEN 'Weekly'   THEN DATEDIFF(N, DATEADD(WW, -1, CURRENT_TIMESTAMP), CURRENT_TIMESTAMP)
        WHEN 'Daily'    THEN DATEDIFF(N, DATEADD(DD, -1, CURRENT_TIMESTAMP), CURRENT_TIMESTAMP)
        WHEN 'Hourly'   THEN DATEDIFF(N, DATEADD(HH, -1, CURRENT_TIMESTAMP), CURRENT_TIMESTAMP)
        WHEN 'Minute'   THEN DATEDIFF(N, DATEADD(N , -1, CURRENT_TIMESTAMP), CURRENT_TIMESTAMP)
        WHEN 'Manual'   THEN 0
        ELSE 0
    END AS [IntervalMinutes],
    p.[ExecutionOrder]
FROM [dbo].[Profile] p
WHERE p.[RecordStatus] = 'A';
GO

USE [master]
GO
