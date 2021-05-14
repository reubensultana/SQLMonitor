USE [tempdb];
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @SQLCmd nvarchar(max);

SET @SQLCmd = '
IF OBJECT_ID(''dbo.IndexUsageStats'') IS NOT NULL
BEGIN
    DROP TABLE [dbo].[IndexUsageStats];
END';
EXEC sp_executesql @SQLCmd;

-- create temporary storage
CREATE TABLE [dbo].[IndexUsageStats](
	[database_name] [nvarchar](128) NOT NULL,
	[object_id] [int] NOT NULL,
	[object_name] [nvarchar](260) NULL,
	[index_id] [int] NOT NULL,
	[index_name] [nvarchar](130) NULL,
	[user_seeks] [bigint] NOT NULL,
	[user_scans] [bigint] NOT NULL,
	[user_lookups] [bigint] NOT NULL,
    [user_updates] [bigint] NOT NULL
) ON [PRIMARY];

-- retrieve data and store in temporary store
INSERT INTO [dbo].[IndexUsageStats] (
    [database_name]
	,[object_id]
	,[object_name]
	,[index_id]
	,[index_name]
	,[user_seeks]
	,[user_scans]
	,[user_lookups]
    ,[user_updates]
)
SELECT 
    DB_NAME(u.database_id) AS [database_name]
    ,u.object_id
    ,CAST(NULL AS nvarchar(260)) AS [object_name]
    ,u.index_id
    ,CAST(NULL AS nvarchar(130)) AS [index_name]
    ,u.user_seeks
    ,u.user_scans
    ,u.user_lookups
    ,u.user_updates
FROM [sys].[dm_db_index_usage_stats] u
WHERE u.database_id > 4 AND u.object_id > 100
AND DB_NAME(u.database_id) NOT IN ('DBAToolbox', 'SSISDB')
AND DB_NAME(u.database_id) NOT LIKE 'AdventureWorks%'
AND DB_NAME(u.database_id) NOT LIKE 'ReportServer%';

-- update object names
DECLARE @DatabaseName nvarchar(128);
--DECLARE @SqlCmd nvarchar(4000);
DECLARE curDatabases CURSOR READ_ONLY FOR 
    SELECT DISTINCT [database_name]
    FROM [dbo].[IndexUsageStats]
    ORDER BY [database_name] ASC;

OPEN curDatabases;
FETCH NEXT FROM curDatabases INTO @DatabaseName;
WHILE (@@FETCH_STATUS = 0)
BEGIN
    -- PRINT @DatabaseName;
    SET @SqlCmd = N'
UPDATE [tempdb].[dbo].[IndexUsageStats]
SET [object_name] = QUOTENAME(s.[name], ''['') + ''.'' + QUOTENAME(o.[name], ''['')
FROM [' + @DatabaseName + N'].sys.objects o
    INNER JOIN [tempdb].[dbo].[IndexUsageStats] mis ON o.object_id = mis.object_id
    INNER JOIN [' + @DatabaseName + N'].sys.schemas s ON o.schema_id = s.schema_id
WHERE mis.[database_name] = N''' + @DatabaseName + N'''
AND mis.[object_name] IS NULL;';
    -- PRINT @SqlCmd;
    EXEC sp_executesql @SqlCmd;

    SET @SqlCmd = N'
UPDATE [tempdb].[dbo].[IndexUsageStats]
SET [index_name] = QUOTENAME(i.[name], ''['')
FROM [' + @DatabaseName + N'].sys.indexes i
    INNER JOIN [tempdb].[dbo].[IndexUsageStats] u on i.object_id = u.object_id and i.index_id = u.index_id
WHERE u.[database_name] = N''' + @DatabaseName + N'''
AND [index_name] IS NULL AND u.[index_id] > 0;';
    -- PRINT @SqlCmd;
    EXEC sp_executesql @SqlCmd;

    FETCH NEXT FROM curDatabases INTO @DatabaseName;
END
CLOSE curDatabases;
DEALLOCATE curDatabases;

-- the object_id column is necessary only until the object name is retrieved
ALTER TABLE [dbo].[IndexUsageStats] DROP COLUMN [object_id];

-- Determine last service restart date based upon tempdb creation date
DECLARE @last_service_start_date datetime;
SELECT @last_service_start_date = CAST(CONVERT(varchar(19),[create_date], 121) AS datetime) FROM sys.databases WHERE [name] = N'tempdb';

-- return results
SELECT 
    CONVERT(nvarchar(128), SERVERPROPERTY('ServerName')) as [ServerName]
    ,[database_name] AS [DatabaseName]
	,[object_name] AS [ObjectName]
	,[index_id] AS [IndexID]
	,[index_name] AS [IndexName]
	,[user_seeks] AS [UserSeeks]
	,[user_scans] AS [User Scans]
	,[user_lookups] AS [UserLookups]
    ,[user_updates] AS [UserUpdates]
    ,@last_service_start_date AS [LastServiceStartDate]
/*  ,(CASE
        WHEN (([index_id] > 1) AND (([user_seeks]+[user_scans]+[user_lookups] <= 100) OR ([user_seeks]+[user_scans]+[user_lookups] < [user_updates]/20))) 
        THEN 'Potentially unused index'
        WHEN (([index_id] > 0) AND (([user_seeks] > 0) AND ([user_scans]+[user_lookups] > 0))) 
        THEN 'Review index, or review SQL code'
        WHEN (([index_id] = 0) AND ([user_scans]+[user_lookups] > 0)) 
        THEN 'Review index, review SQL code, or consider adding a Clustered index'
        ELSE ''
     END) AS [IndexUsage]
*/
FROM [dbo].[IndexUsageStats]
ORDER BY [database_name], [object_name], [index_id];

SET @SQLCmd = '
IF OBJECT_ID(''dbo.IndexUsageStats'') IS NOT NULL
BEGIN
    DROP TABLE [dbo].[IndexUsageStats];
END';
EXEC sp_executesql @SQLCmd;
