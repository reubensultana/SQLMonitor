-- job history
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @StartDate datetime;
--SET @StartDate = CONVERT(datetime, '{0}', 120);
SET @StartDate = CONVERT(datetime, '2016-11-02 05:28:00', 120);

WITH cteJobHistory AS (
SELECT 
    CONVERT(nvarchar(128), SERVERPROPERTY('ServerName')) AS ServerName,
    j.[job_id] AS [JobID], j.[name] AS [JobName], h.step_id AS [StepID], h.step_name AS [StepName], 
    [msdb].dbo.agent_datetime(h.run_date, h.run_time) AS [LastRunTime],
    h.run_status AS [RunStatus], -- 0 = Failed; 1 = Succeeded; 2 = Retry; 3 = Cancelled
    h.[message] AS [Message]
FROM [msdb].dbo.sysjobs j
    INNER JOIN [msdb].dbo.sysjobhistory h ON j.job_id = h.job_id
WHERE j.enabled = 1 AND h.step_id > 0
)
SELECT * FROM cteJobHistory
WHERE [LastRunTime] > @StartDate
ORDER BY [LastRunTime] DESC, [JobName] ASC, [StepID] ASC;
