SET NOCOUNT ON;

CREATE TABLE #sqlagent_properties (
  auto_start                   INT
  ,msx_server_name             NVARCHAR(128) NULL
  ,sqlagent_type               INT
  ,startup_account             NVARCHAR(128)
  ,sqlserver_restart           INT
  ,jobhistory_max_rows         INT
  ,jobhistory_max_rows_per_job INT
  ,errorlog_file               NVARCHAR(255)
  ,errorlogging_level          INT
  ,error_recipient             NVARCHAR(30) NULL
  ,monitor_autostart           INT
  ,local_host_server           NVARCHAR(128) NULL
  ,job_shutdown_timeout        INT
  ,cmdexec_account             VARBINARY(64) NULL
  ,regular_connections         INT
  ,host_login_name             NVARCHAR(128) NULL
  ,host_login_password         VARBINARY(512) NULL
  ,login_timeout               INT
  ,idle_cpu_percent            INT
  ,idle_cpu_duration           INT
  ,oem_errorlog                INT
  ,sysadmin_only               INT NULL
  ,email_profile               NVARCHAR(64) NULL
  ,email_save_in_sent_folder   INT
  ,cpu_poller_enabled          INT
  ,alert_replace_runtime_tokens INT
);

CREATE TABLE #sqlagent_alerts (
	FailSafeOperator nvarchar(255) NULL,
	NotificationMethod int NULL,
	ForwardingServer nvarchar(255) NULL,
	ForwardingSeverity int NULL,
	ForwardAlways int NULL,
	PagerToTemplate nvarchar(255) NULL,
	PagerCCTemplate nvarchar(255) NULL,
	PagerSubjectTemplate nvarchar(255) NULL,
	PagerSendSubjectOnly int NULL
);

DECLARE @Edition nvarchar(128);
DECLARE @UseDatabaseMail int;
DECLARE @DatabaseMailProfile nvarchar(128);

-- run only on supported Editions
SET @Edition = CAST(SERVERPROPERTY('Edition') AS nvarchar(128));
IF (@Edition LIKE 'Enterprise%') OR (@Edition LIKE 'Business Intelligence%') OR (@Edition LIKE 'Developer%') OR (@Edition LIKE 'Standard%')
BEGIN
    IF EXISTS (SELECT 1 FROM sys.configurations WHERE [name] = 'show advanced options' AND [value] = 0)
    BEGIN
	    EXEC sp_configure 'show advanced options', 1;
	    RECONFIGURE WITH OVERRIDE;
    END
    IF EXISTS (SELECT 1 FROM sys.configurations WHERE [name] = 'Agent XPs' AND [value] = 0)
    BEGIN
	    EXEC sp_configure 'Agent XPs', 1;
	    RECONFIGURE WITH OVERRIDE;
    END

	-- SQL Agent Properties
	INSERT INTO #sqlagent_properties
		EXEC msdb..sp_get_sqlagent_properties;

	-- Mail Profile
	EXEC master.dbo.xp_instance_regread
		N'HKEY_LOCAL_MACHINE',
		N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
		N'UseDatabaseMail',
		@UseDatabaseMail OUTPUT;

	IF (@UseDatabaseMail = 1)
	BEGIN
		-- Mail Profile name
		EXEC master.dbo.xp_instance_regread
			N'HKEY_LOCAL_MACHINE',
			N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
			N'DatabaseMailProfile',
			@DatabaseMailProfile OUTPUT;
	END

	-- check for failsafe operator
	INSERT INTO #sqlagent_alerts
		EXEC sp_MSgetalertinfo;
END

SELECT CONVERT(nvarchar(128), SERVERPROPERTY('ServerName')) AS ServerName,
	auto_start AS [AutoStart]
	,startup_account AS [StartupAccount]
	,jobhistory_max_rows AS [JobHistoryMaxRows]
	,jobhistory_max_rows_per_job AS [JobHistoryMaxRowsPerJob]
	,errorlog_file AS [ErrorLogFile]
	,(CASE @UseDatabaseMail WHEN 1 THEN @DatabaseMailProfile ELSE '' END) AS [EmailProfile]
    ,FailSafeOperator
FROM #sqlagent_properties
    CROSS APPLY #sqlagent_alerts;

DROP TABLE #sqlagent_properties;
DROP TABLE #sqlagent_alerts;
