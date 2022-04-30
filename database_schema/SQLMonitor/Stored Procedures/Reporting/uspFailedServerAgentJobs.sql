IF OBJECT_ID(N'[Reporting].[uspFailedServerAgentJobs]') IS NOT NULL
DROP PROCEDURE [Reporting].[uspFailedServerAgentJobs]
GO

CREATE PROCEDURE [Reporting].[uspFailedServerAgentJobs] 
    @TopRowCount int = 100,
    @ServerName nvarchar(128) = NULL,
    @LastRunTime datetime = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

    SELECT TOP (@TopRowCount) 
        [ServerName], [JobName], [StepID], [StepName], MAX([LastRunTime]) AS [LastRunTime], [RunStatus], COUNT(*) AS [ItemCount]
    FROM [Monitor].[ServerAgentJobsHistory]
    -- [RunStatus] not equal to Successful
    WHERE [RunStatus] <> 1
    -- [ServerName] filter
    AND [ServerName] = COALESCE(NULLIF(REPLACE(@ServerName, '%', ''), ''), [ServerName])
    -- [LastRunTime] as specified or limited to the last 24 hours
    AND [LastRunTime] >= COALESCE(@LastRunTime, DATEADD(hh, -24, CURRENT_TIMESTAMP))
    GROUP BY 
        [ServerName], [JobName], [StepID], [StepName], [RunStatus]
    ORDER BY 
        [ServerName] ASC, [LastRunTime] DESC, [JobName] ASC, [StepID] ASC 

END
GO

-- EXEC [SQLMonitor].[Reporting].[uspFailedServerAgentJobs]
