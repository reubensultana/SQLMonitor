USE [SQLMonitor]
GO

IF OBJECT_ID('[Reporting].[vwErrorLog]') IS NOT NULL
DROP VIEW [Reporting].[vwErrorLog]
GO

CREATE VIEW [Reporting].[vwErrorLog]
AS
WITH cteFailedLoginAttempts
AS (
    SELECT
        [ServerName]
        ,[LogDate]
        ,[ProcessInfo]
        ,[LogText]
        -- Extract Login points
        ,(CHARINDEX('''', [LogText], 0)+1) AS [LoginStartPoint]
        ,((CHARINDEX('''', [LogText], (CHARINDEX('''', [LogText], 0)+1))-1) - (CHARINDEX('''', [LogText], 0))) AS [LoginEndPoint]
        -- Extract IP Address points
        ,(CHARINDEX('[', [LogText], 0)+1) AS [IPStartPoint]
        ,((CHARINDEX(']', [LogText], (CHARINDEX('[', [LogText], 0)+1))-1) - (CHARINDEX('[', [LogText], 0))) AS [IPEndPoint]
        -- Extract Reason points
        ,(CHARINDEX('Reason: ', [LogText], 0)+8) AS [ReasonStartPoint]
        ,((CHARINDEX('[', [LogText], (CHARINDEX('Reason: ', [LogText], 0)+8))-8) - (CHARINDEX('Reason: ', [LogText], 0))) AS [ReasonEndPoint]
    FROM [Monitor].[ServerErrorLog]
)
SELECT 
    [ServerName]
    ,[LogDate]
    ,[ProcessInfo]
    --,[LogText]
    -- Extract Login
    ,SUBSTRING(
        [LogText], 
        [LoginStartPoint], 
        (CASE WHEN [LoginEndPoint] > 0 THEN [LoginEndPoint] ELSE 0 END)
    ) AS [LoginName]
    -- Extract IP Address
    ,REPLACE(
        SUBSTRING(
                [LogText], 
                [IPStartPoint], 
                (CASE WHEN [IPEndPoint] > 0 THEN [IPEndPoint] ELSE 0 END)
        ),
        'CLIENT: ', 
        ''
    ) AS [IPAddress]
    -- Extract Reason
    ,SUBSTRING(
        [LogText], 
        [ReasonStartPoint], 
        [ReasonEndPoint]
    ) AS [ReasonForFailure]
FROM cteFailedLoginAttempts
GO

USE [master]
GO
