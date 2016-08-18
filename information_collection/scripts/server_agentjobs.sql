SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET NOCOUNT ON;

-- Basic Job Information  
;WITH cteJobInfo AS (
	SELECT
		jobsrv.job_id, jobs.name, jobs.enabled, 

		/* -- Only for later version of SQL Server 2005 */
		msdb.dbo.SQLAGENT_SUSER_SNAME(jobs.owner_sid) AS [JobOwner],  
		(SELECT TOP 1 next_scheduled_run_date FROM msdb.dbo.sysjobactivity WHERE job_id = jobsrv.job_id ORDER BY session_id DESC) AS [NextRunDateTime],
        msdb.dbo.agent_datetime(jobsrv.last_run_date, jobsrv.last_run_time) AS [LastRunDateTime],  
		CASE jobsrv.last_run_outcome   
			WHEN 0 THEN 'Failed'  
			WHEN 1 THEN 'Succeeded'
			WHEN 2 THEN 'Retry'
			WHEN 3 THEN 'Cancelled'
			ELSE 'NA' 
		END AS LastRunStatus, 
		jobsrv.last_run_duration,
		CASE 
			WHEN (LEN(CAST(jobsrv.last_run_duration AS varchar(20))) <  3) THEN CAST(jobsrv.last_run_duration AS varchar(6))
			WHEN (LEN(CAST(jobsrv.last_run_duration AS varchar(20))) =  3) THEN LEFT(CAST(jobsrv.last_run_duration AS varchar(6)),1) * 60 + RIGHT(CAST(jobsrv.last_run_duration AS varchar(6)),2)
			WHEN (LEN(CAST(jobsrv.last_run_duration AS varchar(20))) =  4) THEN LEFT(CAST(jobsrv.last_run_duration AS varchar(6)),2) * 60 + RIGHT(CAST(jobsrv.last_run_duration AS varchar(6)),2)
			WHEN (LEN(CAST(jobsrv.last_run_duration AS varchar(20))) >= 5) THEN (LEFT(CAST(jobsrv.last_run_duration AS varchar(20)),LEN(jobsrv.last_run_duration)-4)) * 3600
				+(SUBSTRING(CAST(jobsrv.last_run_duration AS varchar(20)), LEN(jobsrv.last_run_duration)-3, 2)) * 60 + RIGHT(CAST(jobsrv.last_run_duration AS varchar(20)) , 2)
		END AS [LastRunDuration],
		CASE jobsrv.last_run_outcome
			WHEN 1 THEN  
				LEFT(REPLACE(jobsrv.last_outcome_message,'The job succeeded.  The Job was invoked by',''),  
				    CHARINDEX('.',REPLACE(jobsrv.last_outcome_message,'The job succeeded.  The Job was invoked by',''))-1)
			WHEN 0 THEN  
				LEFT(REPLACE(jobsrv.last_outcome_message,'The job failed.  The Job was invoked by',''),  
			        CHARINDEX('.',REPLACE(jobsrv.last_outcome_message,'The job failed.  The Job was invoked by',''))-1)
			WHEN 3 THEN  
				LEFT(REPLACE(jobsrv.last_outcome_message,'The job was stopped prior to completion by ',''),  
			        CHARINDEX('.',REPLACE(jobsrv.last_outcome_message,'The job was stopped prior to completion by ',''))-1)
		END AS [LastInvokedBy],  
		CASE jobsrv.last_run_outcome   
			WHEN 3 THEN  
				LEFT(REPLACE(jobsrv.last_outcome_message,'The job failed.  The Job was invoked by',''),  
			        CHARINDEX('.',REPLACE(jobsrv.last_outcome_message,'The job failed.  The Job was invoked by',''))-1)
			ELSE ''
		END AS [Cancelled/StoppedBy], 
		jobsrv.last_outcome_message [Message]
	FROM msdb.dbo.sysjobservers jobsrv 
		INNER JOIN msdb.dbo.sysjobs jobs on jobsrv.job_id = jobs.job_id  
		LEFT JOIN msdb.dbo.sysjobschedules jobsched on jobsrv.job_id = jobsched.job_id
	WHERE COALESCE(jobsrv.last_run_date,0) <> 0 AND COALESCE(jobsched.next_run_date,0) <>0
)
SELECT 
    CONVERT(nvarchar(128), SERVERPROPERTY('ServerName')) AS ServerName,
    [job_id] AS JobID, [name] AS [JobName], [Enabled], [JobOwner],
	[LastRunDateTime], [LastRunStatus], 
	RIGHT('00'+CAST([LastRunDuration]/3600 AS varchar(10)),2)
		+':'+REPLICATE('0',2-LEN(([LastRunDuration] % 3600)/60))+CAST(([LastRunDuration] % 3600)/60 AS varchar(2))
		+':'+REPLICATE('0',2-LEN(([LastRunDuration] % 3600) %60))+CAST(([LastRunDuration] % 3600)%60 AS varchar(2)) AS [LastRunDuration],
	[NextRunDateTime], [LastInvokedBy], [Cancelled/StoppedBy], [Message]
FROM cteJobInfo
ORDER BY [name];
