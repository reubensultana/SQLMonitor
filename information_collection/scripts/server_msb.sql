--Creation of main table
SET NOCOUNT ON;

DECLARE @XMLOutput bit = 0;

DECLARE @msbresult NVARCHAR (128);
DECLARE @instancename NVARCHAR (128);
SET @instancename = CONVERT(NVARCHAR (128), SERVERPROPERTY ('ServerName'))
DECLARE @EngineEdition INT;
SET @EngineEdition = CONVERT(int, SERVERPROPERTY('EngineEdition'));

CREATE TABLE #MSBChecks
(
   [msb_pk] INT IDENTITY(1,1) NOT NULL,
   [msb_id] VARCHAR(10) NOT NULL,
   [msb_InstanceName] NVARCHAR (128) NULL,
   [msb_name] VARCHAR(255) NOT NULL,
   [msb_check] VARCHAR(255) NOT NULL,
   [msb_result] NVARCHAR (128) NULL,
   [msb_compliant] SMALLINT NULL
  );
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--4.1 Service Accounts and Permissions Check List
-------------------------------------------------

--1.1 Domain environment
INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
VALUES ('1.1', @instancename, 'Domain environment', 'Domain environment', 'N/A', -1);

--1.2 SQL Servers accessed via Internet place in DMZ
INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
VALUES ('1.2', @instancename, 'SQL Servers accessed via Internet place in DMZ ', 'SQL Servers accessed via Internet place in DMZ', 'N/A', -1);

--1.3 - SQL Servers accessed via Internet. Block TCP 1433 and UDP 1434
CREATE TABLE #Tcpport (
	[VALUE] VARCHAR (10),
	[DATA] INT
);

DECLARE @RegistryPath VARCHAR(200);
IF (SERVERPROPERTY('INSTANCENAME')) IS NULL
BEGIN
	SET @RegistryPath = 'Software\Microsoft\MSSQLServer\MSSQLServer\SuperSocketNetLib\Tcp\'
END
ELSE
BEGIN
	SET @RegistryPath='Software\Microsoft\Microsoft SQL Server\'+CONVERT(VARCHAR(25),SERVERPROPERTY('INSTANCENAME')) + '\MSSQLServer\SuperSocketNetLib\Tcp\'
END

--INSERT INTO #MSBChecks (msb_result)
--    SELECT DATA FROM #tcpport

INSERT INTO #tcpport (VALUE, DATA)
    EXEC master.dbo.xp_regread 'HKEY_LOCAL_MACHINE', @RegistryPath, 'tcpPort'

SET @msbresult = (SELECT DATA FROM #tcpport)
IF (@msbresult != 1433)
	INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
	VALUES ('1.3', @instancename, 'SQL Servers accessed via Internet. Block TCP 1433 and UDP 1434', 'SQL Servers accessed via Internet. Block TCP 1433 and UDP 1434 ', @msbresult, 1)
ELSE
BEGIN
	INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
	VALUES ('1.3', @instancename, 'SQL Servers accessed via Internet. Block TCP 1433 and UDP 1434', 'SQL Servers accessed via Internet. Block TCP 1433 and UDP 1434 ', @msbresult, 0)
END
DROP TABLE #tcpport

--1.4 Test and dev servers On Separate network
INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
VALUES ('1.4', @instancename, 'Test and dev servers On Separate network', 'Test and dev servers On Separate network', 'N/A', -1)

--1.5 Dedicated Server
INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
VALUES ('1.5', @instancename, 'Dedicated Server', 'Dedicated Server', 'N/A', -1)

--1.6 SQL Server Agent Service low-privileged domain  account
INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
VALUES ('1.6', @instancename, 'SQL Server Agent Service low-privileged domain  account', 'SQL Server Agent Service low-privileged domain  account ', 'N/A', -1)

--1.7 Local Service account to be member of local users group only
INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
VALUES ('1.7', @instancename, 'Local Service account to be member of local users group only', 'Local Service account to be member of local users group only', 'N/A', -1)

--1.8 Domain service account member of non-privileged groups
INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
VALUES ('1.8', @instancename, 'Domain service account member of non-privileged groups', 'Domain service account member of non-privileged groups ', 'N/A', -1)

--1.9 SQL Server service account Local policy rights
INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
VALUES ('1.9', @instancename, 'SQL Server service account Local policy rights', 'SQL Server service account Local policy rights', 'N/A', -1)

--1.10 SQL Server service account Local policy rights
INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
VALUES ('1.10', @instancename, 'SQL Server service account Local policy rights', 'SQL Server service account Local policy rights', 'N/A', -1)

--1.11 Integration Service account rights
INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
VALUES ('1.11', @instancename, 'Integration Service account rights', 'Integration Service account rights', 'N/A', -1)

--1.12 Deny SQL Server services account to log in locally
INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
VALUES ('1.12', @instancename, 'Deny SQL Server services account to log in locally', 'Deny SQL Server services account to log in locally', 'N/A', -1)

--1.13 SQL Server services account rights permissions “Log on to” the database server only
INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
VALUES ('1.13', @instancename, 'SQL Server services account rights permissions “Log on to” the database server only', 'SQL Server services account rights permissions “Log on to” the database server only', 'N/A', -1)

--1.14 SQL Server Proxy accounts
INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
VALUES ('1.14', @instancename, 'SQL Server Proxy accounts', 'SQL Server Proxy accounts','N/A', -1)

--1.15 SQL Server Proxy accounts permissions to run Job steps only
INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
VALUES ('1.15', @instancename, 'SQL Server Proxy accounts permissions to run Job steps only', 'SQL Server Proxy accounts permissions to run Job steps only', 'N/A', -1)

--1.16 SQL Server Proxy accounts not to run on Admin Windows account
INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
VALUES ('1.16', @instancename, 'SQL Server Proxy accounts not to run on Admin Windows account', 'SQL Server Proxy accounts not to run on Admin Windows account', 'N/A', -1)

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--04.2	- Installation and Patches
INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
VALUES ('2.1', @instancename, 'Avoid SQL Server installation on DC', 'Avoid SQL Server installation on DC ', 'N/A', -1)

CREATE TABLE #hotfixes (
	[SQLServer] VARCHAR (128),
	[LatestHotfix] VARCHAR (128),
	[ServicePack] VARCHAR (128) 
);

-- Source: http://sqlserverbuilds.blogspot.co.uk/
INSERT INTO #hotfixes (SQLServer, LatestHotfix, ServicePack)
    SELECT '2000',      '8.00.2283',    'SP4' UNION ALL 
    SELECT '2005',      '9.00.5324',    'SP4' UNION ALL
    SELECT '2008',      '10.0.6000.29', 'SP4' UNION ALL
    SELECT '2008 R2',   '10.50.6000.34','SP3' UNION ALL
    SELECT '2012',      '11.0.6020.0',  'SP3' UNION ALL
    SELECT '2014',      '12.0.5000.0',  'SP2' UNION ALL
    SELECT '2016',      '13.0.1601.5',  'RTM';

CREATE TABLE #Serverinfo (
    [InstanceName] VARCHAR (128),
    [SQLServerVersion] VARCHAR (128),
    [ServicePack] VARCHAR (128),
    [SQLServerEdition] VARCHAR (128),
    [ServerEdition] VARCHAR(128)
);

DECLARE @ProductVersion varchar(128);
SET @ProductVersion = CONVERT(VARCHAR (128), SERVERPROPERTY('ProductVersion'));

INSERT INTO #Serverinfo (InstanceName, SQLServerVersion, ServicePack, SQLServerEdition, ServerEdition)
SELECT 
	CONVERT(VARCHAR (128), SERVERPROPERTY('ServerName')),
	@ProductVersion, 
	CONVERT(VARCHAR (128), SERVERPROPERTY('ProductLevel')), 
	CONVERT(VARCHAR (128), SERVERPROPERTY('Edition')),

	CASE 
		WHEN @ProductVersion LIKE '8.0%'  THEN '2000'
		WHEN @ProductVersion LIKE '9.0%'  THEN '2005'
		WHEN @ProductVersion LIKE '10.0%' THEN '2008'
		WHEN @ProductVersion LIKE '10.5%' THEN '2008 R2'
        WHEN @ProductVersion LIKE '11.0%' THEN '2012'
        WHEN @ProductVersion LIKE '12.0%' THEN '2014'
	END AS 'ServerEdition';

SET @msbresult = (SELECT SQLServerVersion FROM #Serverinfo)
IF EXISTS(
    SELECT 1 FROM #Serverinfo AS si 
        INNER JOIN #hotfixes AS hf ON si.ServerEdition = hf.SQLServer 
    WHERE si.SQLServerVersion != hf.latesthotfix
    )
BEGIN
	INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
	VALUES ('2.2', @instancename, 'Patches and hotfixes', 'Patches and hotfixes', @msbresult, 0)
END
ELSE
BEGIN
	INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
	VALUES ('2.2', @instancename, 'Patches and hotfixes', 'Patches and hotfixes', @msbresult, 1)
END
	
DROP TABLE #serverinfo
DROP TABLE #hotfixes;

--2.5 - Checks if the Authentication Method is Mixed or SQL
CREATE TABLE #authenticationmode (
	[LoginMode] VARCHAR (128),
	[AuthenticationMode] VARCHAR(128)
);

DECLARE @AuthenticationMode INT

INSERT INTO #authenticationmode (LoginMode, AuthenticationMode)
    EXEC master.sys.xp_loginconfig 'login mode';

IF EXISTS (SELECT 1 FROM #authenticationmode WHERE AuthenticationMode = 'Mixed')
	INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
	VALUES ('2.5', @instancename, 'Authentication mode', 'Authentication mode', 'Mixed mode', 1)
ELSE
BEGIN
	INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
	VALUES ('2.5', @instancename, 'Authentication mode', 'Authentication mode', 'Windows', 0)
END

DROP TABLE #authenticationmode

--2.6 - Ensure that the 'sa' username is renamed
SET @msbresult = (SELECT name FROM sys.syslogins WHERE sid = 0x01)

IF (@msbresult = 'sa')
	INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
		VALUES ('2.6', @instancename, 'Ensure sa user is renamed', 'Ensure sa user is renamed', @msbresult, 0)
ELSE
BEGIN
	INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
		VALUES ('2.6', @instancename, 'Ensure sa user is renamed', 'Ensure sa user is renamed', @msbresult, 1);
END

--2.7 - AdventureWorks, AdventureWorksDW, Northwind and Pubs 
CREATE TABLE #databaseinfo (
	[Database_name] SYSNAME NOT NULL,
	[Database_Size] INT,
	[Remarks] NVARCHAR (128 )NULL
);

INSERT INTO #databaseinfo (database_name,database_size, remarks)
    EXEC sp_databases

SET @msbresult = ''
SELECT @msbresult = @msbresult + COALESCE([database_name] + ', ', '') 
FROM #databaseinfo 
WHERE (database_name IN ('Northwind', 'Pubs') OR database_name LIKE 'AdventureWorks%');

-- remove last comma
IF LEN(@msbresult) >0 
    SET @msbresult = LEFT(@msbresult, LEN(@msbresult)-1)

IF EXISTS (SELECT 1 FROM #databaseinfo WHERE (database_name IN ('Northwind', 'Pubs') OR database_name LIKE 'AdventureWorks%'))
	INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
	VALUES ('2.7', @instancename, 'Sample databases ', 'Sample databases', @msbresult, 0);
ELSE
BEGIN
	INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
	VALUES ('2.7', @instancename, 'Sample databases ', 'Sample databases', @msbresult, 1);
END

DROP TABLE #databaseinfo

--2.8 - Remote Access parameters set to 0
SET @msbresult = CONVERT(NVARCHAR (128),(SELECT VALUE FROM sys.configurations WHERE name = 'Remote Access'))

IF EXISTS (SELECT 1 FROM sys.configurations WHERE name = 'Remote Access' AND VALUE = 1)
	INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
	VALUES ('2.8', @instancename, 'Remote Access Parameter set to 0', 'Remote Access Parameter set to 0',@msbresult, 0);
ELSE 
BEGIN
	INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
	VALUES ('2.8', @instancename, 'Remote Access Parameter set to 0', 'Remote Access Parameter set to 0',@msbresult, 1);
END

--2.9 - Startup Procedure Parameter set to 0
SET @msbresult = CONVERT(NVARCHAR (128),(SELECT VALUE FROM sys.configurations WHERE name = 'scan for startup procs'));

IF EXISTS (SELECT 1 FROM sys.configurations WHERE name = 'scan for startup procs' AND VALUE = 1)
	INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
	VALUES ('2.9', @instancename, 'Startup Procedure Parameter set to 0', 'Startup Procedure Parameter set to 0',@msbresult, 0);
ELSE 
BEGIN
	INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
	VALUES ('2.9', @instancename, 'Startup Procedure Parameter set to 0', 'Startup Procedure Parameter set to 0',@msbresult, 1);
END
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--04.3	SQL Server Settings
---------------------------

--3.1 - Disable the “Named Pipes” network protocol
INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
VALUES ('3.1', @instancename, 'Disable the “Named Pipes” network protocol', 'Disable the “Named Pipes” network protocol', 'N/A', -1);

--3.2 - Auto Restart SQL Server 
INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
VALUES ('3.2', @instancename, 'Auto Restart SQL Server ', 'Auto Restart SQL Server ',  'N/A', -1);
	
--3.3 - Auto Restart SQL Server
INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
VALUES ('3.3', @instancename, 'Auto Restart SQL Server Agent ', 'Auto Restart SQL Server Agent',  'N/A', -1);
	
--3.4 - Auto Restart SQL Server
INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
VALUES ('3.4', @instancename, 'Distributed Transaction Coordinator', 'Distributed Transaction Coordinator',  'N/A', -1);
	
--3.5 - Cross database-ownership chaining set to 0
SET @msbresult = CONVERT(NVARCHAR (128),(SELECT VALUE FROM sys.configurations WHERE name = 'cross db ownership chaining'));

IF EXISTS (SELECT 1 FROM sys.configurations WHERE name = 'cross db ownership chaining' AND VALUE = 0)
	INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
	VALUES ('3.5', @instancename, 'Cross database-ownership chaining set to 0', 'Cross database-ownership chaining set to 0',@msbresult, 1);
ELSE 
BEGIN
	INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
	VALUES ('3.5', @instancename, 'Cross database-ownership chaining set to 0 ', 'Cross database-ownership chaining set to 0',@msbresult, 0);
END	

--3.7 - Data Directory Partition 
INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
VALUES ('3.7', @instancename, 'Dedicated Data Directory Partition', 'Dedicated Data Directory Partition',  'N/A', -1);

--3.8 - Log Directory Partition 
INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
VALUES ('3.8', @instancename, 'Log Directory Partition', 'Log Directory Partition',  'N/A', -1);

--3.9 - Do not enable replication
INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
VALUES ('3.9', @instancename, 'Do not enable replication', 'Do not enable replication',  'N/A', -1);

--3.10 - Database Mail
CREATE TABLE #databasemail (
	[Status] NVARCHAR (128)
);

IF (@EngineEdition = 1 OR @EngineEdition = 2)
BEGIN
    BEGIN TRY
        INSERT INTO #databasemail (Status)
            EXEC msdb.dbo.sysmail_help_status_sp;
        
        SET @msbresult = CONVERT(NVARCHAR (128),(SELECT [Status] FROM #databasemail));
    END TRY
    BEGIN CATCH
        SET @msbresult = 'NOT STARTED';
    END CATCH
    
    IF EXISTS (SELECT * FROM #databasemail)
        INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
        VALUES ('3.10', @instancename, 'Database Mail', 'Database Mail', @msbresult, 1);
    ELSE
    BEGIN
        INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
        VALUES ('3.10', @instancename, 'Database Mail', 'Database Mail', @msbresult, 0);
    END
END
ELSE
BEGIN
    SET @msbresult = N'N/A';
    
    INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
    VALUES ('3.10', @instancename, 'Database Mail', 'Database Mail', @msbresult, 0);
END

DROP TABLE #databasemail

--3.11 - Trace error logging to be disabled
CREATE TABLE #tracemessage
(
	[auto_start] NVARCHAR (128),
	[msx_server_name] NVARCHAR (128),
	[sqlagent_type] NVARCHAR (128),
	[startup_account] NVARCHAR (128),
	[sqlserver_restart] NVARCHAR (128),
	[jobhistory_max_rows] NVARCHAR (128),
	[jobhistory_max_rows_per_job] NVARCHAR (128),
	[errorlog_file] NVARCHAR (128),
	[errorlogging_level] NVARCHAR (128),
	[error_recipient] NVARCHAR (128),
	[monitor_autostart] NVARCHAR (128),
	[local_host_server] NVARCHAR (128),
	[job_shutdown_timeout] NVARCHAR (128),
	[cmdexec_account] NVARCHAR (128),
	[regular_connections] NVARCHAR (128),
	[host_login_name] NVARCHAR (128),
	[host_login_password] NVARCHAR (128),
	[login_timeout] NVARCHAR (128),
	[idle_cpu_percent] NVARCHAR (128),
	[idle_cpu_duration] NVARCHAR (128),
	[oem_errorlog] NVARCHAR (128),
	[sysadmin_only] NVARCHAR (128),
	[email_profile] NVARCHAR (128),
	[email_save_in_sent_folder] NVARCHAR (128),
	[cpu_poller_enabled] NVARCHAR (128),
	[alert_replace_runtime_tokens] NVARCHAR (128)
);

IF (@EngineEdition = 1 OR @EngineEdition = 2)
BEGIN
    BEGIN TRY
        INSERT INTO #tracemessage
            EXEC msdb.dbo.sp_get_sqlagent_properties
            --sp_set_sqlagent_properties @errorlogging_level=7 (to enable trace logging)
            --sp_set_sqlagent_properties @errorlogging_level=3 (to disable trace logging)
        
        SET @msbresult = CONVERT(NVARCHAR (128),(SELECT errorlogging_level FROM #tracemessage));
    END TRY
    BEGIN CATCH
        SET @msbresult = 'N/A';
    END CATCH

    IF (@msbresult = '7')
	    INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
	    VALUES ('3.11', @instancename, 'Trace Messages to be set to 3', 'Trace Messages to be set to 3', @msbresult, 0);
    ELSE
    BEGIN
	    INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
	    VALUES ('3.11', @instancename, 'Trace Messages to be set to 3', 'Trace Messages to be set to 3', @msbresult, 1);
    END
END
ELSE
BEGIN
    SET @msbresult = N'N/A';
    
    INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
    VALUES ('3.11', @instancename, 'Trace Messages to be set to 3', 'Trace Messages to be set to 3', @msbresult, 0);
END

DROP TABLE #tracemessage

--3.12 - Don't use User-defined extended stored procedures
INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
VALUES ('3.12', @instancename, 'Dont use User-defined extended stored procedures', 'Dont use User-defined extended stored procedures', 'N/A', -1);

--3.18 - SQL Server Event forwarding
CREATE TABLE #eventforwarding (
	[AlertFailSafeOperator] NVARCHAR (128),
	[AlertNotificationMethod] NVARCHAR (128),
	[AlertForwardingServer] NVARCHAR (128) NULL,
	[AlertForwardingSeverity] NVARCHAR (128),
	[AlertPagerToTemplate] NVARCHAR (128),
	[AlertPagerCCTemplate] NVARCHAR (128),
	[AlertPagerSubjectTemplate] NVARCHAR (128),
	[AlertPagerSendSubjectOnly] NVARCHAR (128),
	[AlertForwardAlways] NVARCHAR (128)
);

INSERT INTO #eventforwarding (AlertFailSafeOperator, AlertNotificationMethod, AlertForwardingServer, AlertForwardingSeverity, AlertPagerToTemplate, AlertPagerCCTemplate, AlertPagerSubjectTemplate, AlertPagerSendSubjectOnly, AlertForwardAlways)
    EXEC sp_MSgetalertinfo

SET @msbresult = (SELECT CONVERT(NVARCHAR (128), AlertForwardingServer) FROM #eventforwarding);
IF (@msbresult IS NOT NULL)
	INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
	VALUES ('3.13', @instancename, 'SQL Server Event forwarding', 'SQL Server Event forwarding', @msbresult, 0);
ELSE
BEGIN
	INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
	VALUES ('3.13', @instancename, 'SQL Server Event forwarding', 'SQL Server Event forwarding','Disabled', 1);
END

DROP TABLE #eventforwarding

--3.19 - Disable SQL Server Browser Service 
INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
VALUES ('3.14', @instancename, 'Disable SQL Server Browser Service ', 'Disable SQL Server Browser Service ',  'N/A', -1);
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--04.4	Access Controls
-----------------------

--4.1 - SQL Server install directory permissions 
INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
VALUES ('4.1', @instancename, 'SQL Server install directory permissions', 'SQL Server install directory permissions',  'N/A', -1);

--4.2 - SQL Server database instance directory permissions
INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
VALUES ('4.2', @instancename, 'SQL Server install directory permissions', 'SQL Server install directory permissions',  'N/A', -1);

---4.3 - Assigning System Administrators role 
INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
VALUES ('4.3', @instancename, 'Assigning System Administrators role ', 'Assigning System Administrators role ', 'N/A', -1);

IF EXISTS (SELECT 1 FROM sys.syslogins WHERE name = 'BUILTIN\Administrators')
	INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
	VALUES ('4.4', @instancename, 'Remove the default BUILTIN\Administrators', 'Remove the default BUILTIN\Administrators', 'Login exists', 0)
ELSE
BEGIN
	INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
	VALUES ('4.4', @instancename, 'Remove the default BUILTIN\Administrators', 'Remove the default BUILTIN\Administrators', 'Login does not exist', 1);
END

--4.5 - SQL Logins Password Strength
SET @msbresult = CONVERT (NVARCHAR (128), (SELECT COUNT(is_policy_checked) AS No_Policy FROM sys.sql_logins WHERE is_policy_checked = 0)) 
IF @msbresult = 0
	INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
	VALUES ('4.5', @instancename, 'SQL Logins Password Strength', 'SQL Logins Password Strength', @msbresult, 1)
ELSE
BEGIN
	INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
	VALUES ('4.5', @instancename, 'SQL Logins Password Strength', 'SQL Logins Password Strength', @msbresult, 0)
END

--4.6 - Guest Account Access Denied
IF EXISTS (SELECT * FROM sys.syslogins WHERE denylogin = 1 AND name LIKE '%\guest')
	INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
	VALUES ('4.6', @instancename, 'Guest Account Access Denied', 'Guest Account Access Denied', 'Access Denied', 1)
ELSE
BEGIN
	INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
	VALUES ('4.6', @instancename, 'Guest Account Access Denied', 'Guest Account Access Denied', 'Access Granted', 0)
END

--4.7 - Use sysadmin, serveradmin, setupadmin etc, to support DBA activity
INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
VALUES ('4.7', @instancename, 'Use sysadmin, serveradmin, setupadmin etc, to support DBA activity', 'Use sysadmin, serveradmin, setupadmin etc, to support DBA activity',  'N/A', -1);

--4.9 DDL statement permissions to schema owner only
INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
VALUES ('4.9', @instancename, 'DDL statement permissions to schema owner only', 'DDL statement permissions to schema owner only',  'N/A', -1);

--4.10 Ensure dbo owns all user-created database schemas 
DECLARE @DatabaseNames CURSOR;				-- Databases to be checked
DECLARE @DatabaseName NVARCHAR(128);		-- Database name
DECLARE @SQLcmd1 NVARCHAR(4000);			-- holds dynamic SQL TEMPLATE used within loop
DECLARE @SQLcmd2 NVARCHAR(4000);			-- holds dynamic SQL EXECUTED used within loop
DECLARE @ParmDefinition NVARCHAR(500);
DECLARE @ItemCountSub INT; -- Subtotal
DECLARE @TotalItemCount INT; -- Total

SET @ParmDefinition = N'@ItemCount int OUTPUT';
SET @SQLcmd1 = N'
SELECT @ItemCount = COUNT(dp.name) 
FROM [%d].sys.schemas AS s 
INNER JOIN [%d].sys.database_principals AS dp ON dp.principal_id = s.principal_id 
WHERE dp.name != ''dbo'' AND dp.name NOT IN (
	''db_owner'',''db_accessadmin'',''db_securityadmin'',''db_ddladmin'',''db_backupoperator'',''db_datareader'',
	''db_datawriter'',''db_denydatareader'',''db_denydatawriter'',''guest'',''INFORMATION_SCHEMA'',''sys'')';

SET @ItemCountSub = 0;
SET @TotalItemCount = 0;

SET @DatabaseNames = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
    SELECT [name] FROM sys.databases
    WHERE database_id > 4 -- exclude master, tempdb, model, msdb
		AND [name] NOT IN ('AdventureWorks','AdventureWorksDW','AdventureWorksLT','db_dba')
		AND [name] NOT LIKE 'ReportServer%'
		--AND ISNULL(DATABASEPROPERTY([name], 'IsReadOnly'), 0) = 0
		AND ISNULL(DATABASEPROPERTY([name], 'IsOffline'), 0) = 0
		AND ISNULL(DATABASEPROPERTY([name], 'IsSuspect'), 0) = 0
		AND ISNULL(DATABASEPROPERTY([name], 'IsShutDown'), 0) = 0
		AND ISNULL(DATABASEPROPERTY([name], 'IsNotRecovered'), 0) = 0
		AND ISNULL(DATABASEPROPERTY([name], 'IsInStandBy'), 0) = 0
		AND ISNULL(DATABASEPROPERTY([name], 'IsInRecovery'), 0) = 0
		AND ISNULL(DATABASEPROPERTY([name], 'IsInLoad'), 0) = 0
		AND ISNULL(DATABASEPROPERTY([name], 'IsEmergencyMode'), 0) = 0
		AND ISNULL(DATABASEPROPERTY([name], 'IsDetached'), 0) = 0

OPEN @DatabaseNames
FETCH NEXT FROM @DatabaseNames INTO @DatabaseName
WHILE (@@FETCH_STATUS = 0)
BEGIN
	SET @SQLcmd2 = REPLACE(@SQLcmd1, '%d', @DatabaseName);
    --PRINT @SQLcmd2;

	EXECUTE sp_executesql @SQLcmd2, @ParmDefinition, @ItemCount=@ItemCountSub OUTPUT;
	--PRINT @DatabaseName + ': ' + CAST(@ItemCountSub AS nvarchar(5))
		
	SET @TotalItemCount = @TotalItemCount + @ItemCountSub;
		
    FETCH NEXT FROM @DatabaseNames INTO @DatabaseName
END
CLOSE @DatabaseNames
DEALLOCATE @DatabaseNames

SET @msbresult = @TotalItemCount;

IF @msbresult = 0
	INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
	VALUES ('4.10', @instancename, 'SQL Logins Password Strength', 'SQL Logins Password Strength', @msbresult, 1)
ELSE
BEGIN
	INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
	VALUES ('4.10', @instancename, 'SQL Logins Password Strength', 'SQL Logins Password Strength', @msbresult, 0)
END

--4.11 Low-privileged users 
INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
VALUES ('4.11', @instancename, 'Low-privileged users', 'Low-privileged users ',  'N/A', -1);

--4.12
INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
VALUES ('4.12', @instancename, 'Stored Procedure Permissions ', 'Stored Procedure Permissions ',  'N/A', -1);

--4.13 Users should not have with grant option
DECLARE @DatabaseName413s413 CURSOR;		-- Databases to be checked
DECLARE @DatabaseName413 NVARCHAR(128);		-- Database name
DECLARE @select413 NVARCHAR (128);			-- holds dynamic SQL TEMPLATE used within loop
DECLARE @count413 NVARCHAR (1000);			-- holds dynamic SQL EXECUTED used within loop
DECLARE @ParmDefinitiont413 NVARCHAR(500);
DECLARE @ItemCountSubt413 INT; -- Subtotal
DECLARE @TotalItemCount413 INT; -- Total

SET @ParmDefinitiont413 = N'@ItemCount int OUTPUT';
SET @select413 = N'SELECT @ItemCount = COUNT(*)
FROM [%d].sys.database_permissions
WHERE state_desc = ''GRANT_WITH_GRANT_OPTION''';

SET @ItemCountSubt413 = 0;
SET @TotalItemCount413 = 0;

SET @DatabaseName413s413 = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
    SELECT [name] FROM sys.databases
    WHERE database_id > 4 -- exclude master, tempdb, model, msdb
		AND [name] NOT IN ('AdventureWorks','AdventureWorksDW','AdventureWorksLT','db_dba')
		AND [name] NOT LIKE 'ReportServer%'
		--AND ISNULL(DATABASEPROPERTY([name], 'IsReadOnly'), 0) = 0
		AND ISNULL(DATABASEPROPERTY([name], 'IsOffline'), 0) = 0
		AND ISNULL(DATABASEPROPERTY([name], 'IsSuspect'), 0) = 0
		AND ISNULL(DATABASEPROPERTY([name], 'IsShutDown'), 0) = 0
		AND ISNULL(DATABASEPROPERTY([name], 'IsNotRecovered'), 0) = 0
		AND ISNULL(DATABASEPROPERTY([name], 'IsInStandBy'), 0) = 0
		AND ISNULL(DATABASEPROPERTY([name], 'IsInRecovery'), 0) = 0
		AND ISNULL(DATABASEPROPERTY([name], 'IsInLoad'), 0) = 0
		AND ISNULL(DATABASEPROPERTY([name], 'IsEmergencyMode'), 0) = 0
		AND ISNULL(DATABASEPROPERTY([name], 'IsDetached'), 0) = 0

OPEN @DatabaseName413s413
FETCH NEXT FROM @DatabaseName413s413 INTO @DatabaseName413
WHILE (@@FETCH_STATUS = 0)
BEGIN
	SET @count413 = REPLACE(@select413, '%d', @DatabaseName413);
    --PRINT @select413;

	EXECUTE sp_executesql @count413, @ParmDefinitiont413, @ItemCount=@ItemCountSubt413 OUTPUT;
	--PRINT @DatabaseName413 + ': ' + CAST(@ItemCountSubt413 AS nvarchar(5))
		
	SET @TotalItemCount413 = @TotalItemCount413 + @ItemCountSubt413;

FETCH NEXT FROM @DatabaseName413s413 INTO @DatabaseName413
END
CLOSE @DatabaseName413s413
DEALLOCATE @DatabaseName413s413

SET @msbresult = @TotalItemCount413

IF @msbresult = 0
	INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
	VALUES ('4.13', @instancename, 'Users should not have with grant option', 'Users should not have with grant option', @msbresult, 1)
ELSE
BEGIN
	INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
	VALUES ('4.13', @instancename, 'Users should not have with grant option', 'Users should not have with grant option', @msbresult, 0)
END

--4.14 - SQL Server Agent subsystem privileges 
INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
VALUES ('4.14', @instancename, 'SQL Server Agent subsystem privileges ', 'SQL Server Agent subsystem privileges ',  'N/A', -1);

--4.15 - SQL Server database instance directory permissions
INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
VALUES ('4.15', @instancename, 'User-defined Database Roles', 'User-defined Database Roles',  'N/A', -1);

--4.16 - Database Roles 
INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
VALUES ('4.16', @instancename, 'Database Roles', 'Database Roles',  'N/A', -1);

--4.17 - Users and Roles
INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
VALUES ('4.17', @instancename, 'Users and Roles ', 'Users and Roles',  'N/A', -1);

--4.18 - Application Roles
INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
VALUES ('4.18', @instancename, 'Application Roles', 'Application Roles',  'N/A', -1);

--4.19 - Use of Predefined Roles 
INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
VALUES ('4.19', @instancename, 'Use of Predefined Roles', 'Use of Predefined Roles',  'N/A', -1);

--4.20 - Linked or Remote Servers
INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
VALUES ('4.20', @instancename, 'Linked or Remote Servers', 'Linked or Remote Servers',  'N/A', -1);

--4.21 - Linked or Remote Servers
INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
VALUES ('4.21', @instancename, 'Linked or Remote Servers', 'Linked or Remote Servers',  'N/A', -1);

--4.22 - Linked Server logins
INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
VALUES ('4.22', @instancename, 'Linked Server logins', 'Linked Server logins',  'N/A', -1);

--4.23 - Ad Hoc Data Access
INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
VALUES ('4.23', @instancename, 'Ad Hoc Data Access', 'Ad Hoc Data Access',  'N/A', -1);

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--4.6	Backups and Disaster Recovery
--------------------------------------

--6.1- Backups – General 
INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
VALUES ('6.1', @instancename, 'Backups – General ', 'Backups – General ',  'N/A', -1);

--6.2 - System databases
INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
VALUES ('6.2', @instancename, 'System databases', 'System databases',  'N/A', -1);

--6.3 - Access to Backup Files 
INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
VALUES ('6.3', @instancename, 'Access to Backup Files', 'Access to Backup Files',  'N/A', -1);

--6.4 - Access to Backup Files for restore
INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
VALUES ('6.4', @instancename, 'Access to Backup Files for restore', 'Access to Backup Files for restore',  'N/A', -1);

--6.5 - Enable Password Policy Enforcement 
INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
VALUES ('6.5', @instancename, 'Enable Password Policy Enforcement', 'Enable Password Policy Enforcement',  'N/A', -1);

--6.6- Periodic scan of Role Members 
INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
VALUES ('6.6', @instancename, 'Periodic scan of Role Members', 'Periodic scan of Role Members',  'N/A', -1);

--6.7 - Periodic scan of stored procedures 
INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
VALUES ('6.7', @instancename, 'Periodic scan of stored procedures', 'Periodic scan of stored procedures',  'N/A', -1);

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--4.7	Replication
--------------------------------------
--7.1 - SQL Server Agent service account
INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
VALUES ('7.1', @instancename, 'SQL Server Agent service account', 'SQL Server Agent service account',  'N/A', -1);

--7.2 - Periodic scan of stored procedures 
INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
VALUES ('7.2', @instancename, 'Replication administration roles', 'Replication administration roles',  'N/A', -1);

--7.3 - Snapshot share folder
INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
VALUES ('7.3', @instancename, 'Snapshot share folder', 'Snapshot share folder',  'N/A', -1);

--7.4 - Publication Access List 
INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
VALUES ('7.4', @instancename, 'Publication Access List', 'Publication Access List',  'N/A', -1);

--7.5 - Secure Communications
INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
VALUES ('7.5', @instancename, 'Secure Communications', 'Secure Communications',  'N/A', -1);

--7.6 - Database connections
INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
VALUES ('7.6', @instancename, 'Database connections', 'Database connections',  'N/A', -1);

--7.7 - Filtering 
INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
VALUES ('7.7', @instancename, 'Filtering', 'Filtering',  'N/A', -1);

--7.8 - Distribution databases
INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
VALUES ('7.8', @instancename, 'Distribution databases', 'Distribution databases',  'N/A', -1);

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--4.8 Surface Area Configuration Tool
--------------------------------------

--8.1 Disable Ad Hoc Remote Queries where not required
IF EXISTS (SELECT 1 FROM sys.configurations WHERE name = 'Ad Hoc Distributed Queries' AND value = 0)
  	INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
	VALUES ('8.1', @instancename, 'Disable Ad Hoc Remote Queries where not required', 'Disable Ad Hoc Remote Queries where not required','Disabled', 1)
ELSE
BEGIN
	INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
	VALUES ('8.1', @instancename, 'Disable Ad Hoc Remote Queries where not required', 'Disable Ad Hoc Remote Queries where not required','Enabled', 0)
END

--8.2 Disable CLR Integration where not required
IF EXISTS (SELECT 1 FROM sys.configurations WHERE name = 'clr enabled' AND value = 0)
  	INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
	VALUES ('8.2', @instancename, 'Disable CLR Integration where not required', 'Disable CLR Integration where not required','Disabled', 1)
ELSE
BEGIN
	INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
	VALUES ('8.2', @instancename, 'Disable CLR Integration where not required', 'Disable CLR Integration where not required','Enabled', 0)
END

--8.3 Disable the remote Dedicated Administrator Connection where not required
IF EXISTS (SELECT 1 FROM sys.configurations WHERE name = 'remote admin connections' AND value = 0)
  	INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
	VALUES ('8.3', @instancename, 'Disable the remote Dedicated Administrator Connection where not required', 'Disable the remote Dedicated Administrator Connection where not required', 'Disabled', 1)
ELSE
BEGIN
	INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
	VALUES ('8.3', @instancename, 'Disable the remote Dedicated Administrator Connection where not required', 'Disable the remote Dedicated Administrator Connection where not required', 'Enabled', 0)
END

--8.5 - Native XML Web Services 
INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
VALUES ('8.5', @instancename, 'Native XML Web Services', 'Native XML Web Services',  'N/A', -1);

--8.6
IF EXISTS (SELECT 1 FROM sys.configurations WHERE name = 'OLE Automation Procedures' AND value = 0)
  	INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
	VALUES ('8.6', @instancename, 'Disable OLE Automation where not required', 'Disable OLE Automation where not required', 'Disabled', 1)
ELSE
BEGIN
	INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
	VALUES ('8.6', @instancename, 'Disable OLE Automation where not required', 'Disable OLE Automation where not required', 'Enabled', 0)
END

--8.7 Service Broker
INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
VALUES ('8.7', @instancename, 'Service Broker', 'Service Broker',  'N/A', -1);

--8.8 Do not enable SQL Mail where not required
IF EXISTS (SELECT 1 FROM sys.configurations WHERE name = 'SQL Mail XPs' AND value = 0)
  	INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
	VALUES ('8.8', @instancename, 'Do not enable SQL Mail where not required', 'Do not enable SQL Mail where not required', 'Disabled', 1)
ELSE
BEGIN
	INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
	VALUES ('8.8', @instancename, 'Do not enable SQL Mail where not required', 'Do not enable SQL Mail where not required', 'Enabled', 0)
END

--8.9 Web Assistant Feature
IF EXISTS (SELECT 1 FROM sys.configurations WHERE name = 'Web Assistant Procedures')
BEGIN  
	IF EXISTS (SELECT 1 FROM sys.configurations WHERE name = 'Web Assistant Procedures' and value = 1)
		INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
		VALUES ('8.9', @instancename, 'Web Assistant Feature ', 'Web Assistant Feature ', 'Enabled', 1);
	ELSE
		INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
		VALUES ('8.9', @instancename, 'Web Assistant Feature ', 'Web Assistant Feature ', 'Disabled', 0);
END
ELSE
BEGIN
	INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
	VALUES ('8.9', @instancename, 'Web Assistant Feature ', 'Web Assistant Feature ', 'Does not exist', NULL);
END

--8.10 Disable xp_cmdshell
IF EXISTS (SELECT 1 FROM sys.configurations WHERE name = 'xp_cmdshell' and value = 1)
BEGIN
	INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
	VALUES ('8.10', @instancename, 'xp_cmdshell', 'xp_cmdshell', 'Enabled', 0);
END
ELSE
BEGIN
	INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
	VALUES ('8.10', @instancename, 'xp_cmdshell', 'xp_cmdshell', 'Disabled', 1);
END

-- 8.11 Ad Hoc Data Mining 
IF EXISTS (SELECT 1 FROM sys.configurations WHERE name = 'Ad Hoc Distributed Queries' and value = 1)
BEGIN
	INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
	VALUES ('8.11', @instancename, 'Ad Hoc Data Mining', 'Ad Hoc Data Mining', 'Enabled', 0);
END
ELSE
BEGIN
	INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
	VALUES ('8.11', @instancename, 'Ad Hoc Data Mining', 'Ad Hoc Data Mining', 'Disabled', 1);
END

--8.12 Anonymous Connections 
INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
VALUES ('8.12', @instancename, 'Anonymous Connections', 'Anonymous Connections',  'N/A', -1);

--8.13 Linked Objects
INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
VALUES ('8.13', @instancename, 'Linked Objects', 'Linked Objects',  'N/A', -1);

--8.14 Linked Objects 
INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
VALUES ('8.14', @instancename, 'Linked Objects', 'Linked Objects',  'N/A', -1);

--8.15 User-Defined Functions
INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
VALUES ('8.15', @instancename, 'User-Defined Functions', 'User-Defined Functions',  'N/A', -1);

--8.16 Scheduled Events and Report Delivery
INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
VALUES ('8.16', @instancename, 'Scheduled Events and Report Delivery', 'Scheduled Events and Report Delivery',  'N/A', -1);

--8.17 Web Service and HTTP Access
INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
VALUES ('8.17', @instancename, 'Web Service and HTTP Access', 'Web Service and HTTP Access',  'N/A', -1);

--8.18 Windows Integrated Security
INSERT INTO #MSBChecks (msb_id, msb_Instancename, msb_name, msb_check, msb_result, msb_compliant)
VALUES ('8.18', @instancename, 'Windows Integrated Security', 'Windows Integrated Security',  'N/A', -1);

IF (@XMLOutput = 1)  -- output results as XML
BEGIN
    SELECT msb_id, msb_InstanceName, msb_name, msb_check, msb_result,
        CASE msb_compliant 
            WHEN -1 THEN 'Manual'
            WHEN 0 THEN 'Failed'
            WHEN 1 THEN 'Pass'
            ELSE 'N/A'
        END AS [msb_compliant]
    FROM #MSBChecks
    ORDER BY msb_pk ASC
    FOR XML RAW, XMLSCHEMA, ROOT('msb'), ELEMENTS XSINIL;
END
ELSE
BEGIN
    SELECT msb_id, msb_InstanceName, msb_name, msb_check, msb_result,
        CASE msb_compliant 
            WHEN -1 THEN 'Manual'
            WHEN 0 THEN 'Failed'
            WHEN 1 THEN 'Pass'
            ELSE 'N/A'
        END AS [msb_compliant]
    FROM #MSBChecks
    ORDER BY msb_pk ASC;
END

DROP table #MSBChecks
