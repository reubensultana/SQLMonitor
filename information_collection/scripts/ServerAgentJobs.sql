-- job information
USE [tempdb];

DECLARE @SQLCmd nvarchar(max);

SET @SQLCmd = '
IF OBJECT_ID(''dbo.fn_JobInterval'') IS NOT NULL
BEGIN
    DROP FUNCTION dbo.fn_JobInterval;
END';
EXEC sp_executesql @SQLCmd;

SET @SQLCmd = '
CREATE FUNCTION dbo.fn_JobInterval (@IntervalValue int)
RETURNS varchar(max)
WITH EXECUTE AS CALLER
AS
BEGIN
    DECLARE @JobInterval varchar(max);
    WITH cteIntervals AS (
        SELECT @IntervalValue AS IntervalValue, IntervalDescription 
        FROM (
            SELECT 1 AS IntervalValue, ''Sunday'' AS IntervalDescription UNION ALL 
            SELECT 2, ''Monday'' UNION ALL
            SELECT 4, ''Tuesday'' UNION ALL
            SELECT 8, ''Wednesday'' UNION ALL
            SELECT 16, ''Thursday'' UNION ALL
            SELECT 32, ''Friday'' UNION ALL 
            SELECT 64, ''Saturday''
        ) a
        WHERE @IntervalValue & IntervalValue > 0
    )
    SELECT @JobInterval = (
        SELECT STUFF( (SELECT '','' + IntervalDescription 
                    FROM cteIntervals p2
                    WHERE p2.IntervalValue = p1.IntervalValue
                    ORDER BY IntervalValue
                    FOR XML PATH(''''), TYPE).value(''.'', ''varchar(max)'')
                ,1,1,'''') AS Products
        FROM cteIntervals p1
        GROUP BY IntervalValue
    );
    RETURN (@JobInterval);
END';
EXEC sp_executesql @SQLCmd;

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET NOCOUNT ON;
SELECT 
    CONVERT(nvarchar(128), SERVERPROPERTY('ServerName')) AS [ServerName],
    j.[job_id] AS [JobID], 
    j.[name] AS [JobName], 
    j.[Enabled], 
    msdb.dbo.SQLAGENT_SUSER_SNAME(j.owner_sid) AS [JobOwner],
    j.[date_created] AS [DateCreated], 
    j.[date_modified] AS [DateModified],
    -- job details with step/s as XML
    CAST((
        SELECT 
            step_id, step_name, subsystem, command, database_name, proxy_id,
            on_success_action, on_success_step_id, on_fail_action, on_fail_step_id
        FROM [msdb].dbo.sysjobsteps
        WHERE job_id = j.job_id
        ORDER BY step_id
        FOR XML PATH('jobstep'), ROOT('jobsteps'), ELEMENTS XSINIL
    ) AS XML) AS [JobSteps],
    -- job details with schedule/s as XML
    CAST((
        SELECT 
            s.name AS schedule_name, 
            [msdb].dbo.agent_datetime(s.active_start_date, s.active_start_time) AS schedule_time, 
            --s.freq_type, s.freq_interval, s.freq_relative_interval, 
            CASE s.freq_type
                WHEN 1 THEN 'One time only'
                WHEN 4 THEN 'Daily'
                WHEN 8 THEN 'Weekly on ' + dbo.fn_JobInterval(s.freq_interval)
                WHEN 16 THEN 'Monthly, on the ' + CAST(s.freq_interval as varchar(10)) + ' of the month'
                WHEN 32 THEN 'Monthly, on the ' + (
                    CASE s.freq_relative_interval
                        WHEN 1 THEN  'first'
                        WHEN 2 THEN  'second'
                        WHEN 4 THEN  'third'
                        WHEN 8 THEN  'fourth'
                        WHEN 16 THEN 'last'
                        ELSE ''
                    END ) + ' ' + (
                    CASE s.freq_interval
                        WHEN 1 THEN  'Sunday'
                        WHEN 2 THEN  'Monday'
                        WHEN 3 THEN  'Tuesday'
                        WHEN 4 THEN  'Wednesday'
                        WHEN 5 THEN  'Thursday'
                        WHEN 6 THEN  'Friday'
                        WHEN 7 THEN  'Saturday'
                        WHEN 8 THEN  'Day'
                        WHEN 9 THEN  'Weekday'
                        WHEN 10 THEN 'Weekend day'
                        ELSE ''
                    END )
                WHEN 64 THEN 'When the SQL Server Agent service starts'
                WHEN 128 THEN 'When the computer is idle'
                ELSE ''
            END AS [schedule_frequency],
            s.[enabled] AS [schedule_status]
        FROM [msdb].dbo.sysschedules s
            INNER JOIN [msdb].dbo.sysjobschedules js ON s.schedule_id = js.schedule_id
        WHERE js.job_id = j.job_id
        ORDER BY [msdb].dbo.agent_datetime(s.active_start_date, s.active_start_time)
        FOR XML PATH('jobschedule'), ROOT('jobschedules'), ELEMENTS XSINIL
    ) AS XML) AS [JobSchedules]
FROM [msdb].dbo.sysjobs j;

SET @SQLCmd = '
IF OBJECT_ID(''dbo.fn_JobInterval'') IS NOT NULL
BEGIN
    DROP FUNCTION dbo.fn_JobInterval;
END';
EXEC sp_executesql @SQLCmd;
