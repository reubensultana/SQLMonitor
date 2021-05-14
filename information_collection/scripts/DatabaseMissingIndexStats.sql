USE [tempdb];
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @SQLCmd nvarchar(max);

SET @SQLCmd = '
IF OBJECT_ID(''dbo.[MissingIndexStats]'') IS NOT NULL
BEGIN
    DROP TABLE [dbo].[MissingIndexStats];
END';
EXEC sp_executesql @SQLCmd;

-- create temporary storage
CREATE TABLE [dbo].[MissingIndexStats](
	[database_name] [nvarchar](128) NOT NULL,
	[object_id] [int] NOT NULL,
	[object_name] [nvarchar](260) NULL,
	[equality_columns] [nvarchar](4000) NULL,
	[inequality_columns] [nvarchar](4000) NULL,
	[included_columns] [nvarchar](4000) NULL,
	[unique_compiles] [bigint] NOT NULL,
	[user_seeks] [bigint] NOT NULL,
	[user_scans] [bigint] NOT NULL,
	[avg_total_user_cost] [numeric] (15,2) NULL,
	[avg_user_impact] [numeric] (5,2) NULL
) ON [PRIMARY];

-- retrieve data and store in temporary store
INSERT INTO [dbo].[MissingIndexStats] (
    [database_name]
    ,[object_id]
    ,[object_name]
    ,[equality_columns]
    ,[inequality_columns]
    ,[included_columns]
    ,[unique_compiles]
    ,[user_seeks]
    ,[user_scans]
    ,[avg_total_user_cost]
    ,[avg_user_impact]
)
SELECT 
    DB_NAME(d.database_id) AS [database_name]
    ,d.object_id
    ,CAST(NULL AS nvarchar(260)) AS [object_name]
    ,d.[equality_columns]
    ,d.[inequality_columns]
    ,d.[included_columns]
    ,s.[unique_compiles]
    ,s.[user_seeks]
    ,s.[user_scans]
    ,CAST(s.[avg_total_user_cost] AS numeric(15,2)) AS [avg_total_user_cost]
    ,CAST(s.[avg_user_impact] AS numeric(5,2)) AS [avg_user_impact]
FROM sys.dm_db_missing_index_groups g
    INNER JOIN sys.dm_db_missing_index_details d ON d.index_handle = g.index_handle
    INNER JOIN sys.dm_db_missing_index_group_stats s ON s.group_handle = g.index_group_handle
WHERE d.database_id > 4
AND DB_NAME(d.database_id) NOT IN ('DBAToolbox', 'SSISDB')
AND DB_NAME(d.database_id) NOT LIKE 'AdventureWorks%'
AND DB_NAME(d.database_id) NOT LIKE 'ReportServer%';

-- update object names
DECLARE @DatabaseName nvarchar(128);
--DECLARE @SqlCmd nvarchar(4000);
DECLARE curDatabases CURSOR READ_ONLY FOR 
    SELECT DISTINCT [database_name]
    FROM [dbo].[MissingIndexStats]
    ORDER BY [database_name] ASC;

OPEN curDatabases;
FETCH NEXT FROM curDatabases INTO @DatabaseName;
WHILE (@@FETCH_STATUS = 0)
BEGIN
    -- PRINT @DatabaseName;
    SET @SqlCmd = N'
UPDATE [tempdb].[dbo].[MissingIndexStats]
SET [object_name] = QUOTENAME(s.[name], ''['') + ''.'' + QUOTENAME(o.[name], ''['')
FROM [' + @DatabaseName + N'].sys.objects o
    INNER JOIN [tempdb].[dbo].[MissingIndexStats] mis ON o.object_id = mis.object_id
    INNER JOIN [' + @DatabaseName + N'].sys.schemas s ON o.schema_id = s.schema_id
WHERE mis.[database_name] = N''' + @DatabaseName + N'''
AND mis.[object_name] IS NULL;';
    -- PRINT @SqlCmd;
    EXEC sp_executesql @SqlCmd;

    FETCH NEXT FROM curDatabases INTO @DatabaseName;
END
CLOSE curDatabases;
DEALLOCATE curDatabases;

-- the object_id column is necessary only until the object name is retrieved
ALTER TABLE [dbo].[MissingIndexStats] DROP COLUMN [object_id];

-- Determine last service restart date based upon tempdb creation date
DECLARE @last_service_start_date datetime;
SELECT @last_service_start_date = [create_date] FROM sys.databases WHERE [name] = N'tempdb';

-- return results
SELECT 
    CONVERT(nvarchar(128), SERVERPROPERTY('ServerName')) as [ServerName]
    ,[database_name] AS [DatabaseName]
    ,[object_name] AS [ObjectName]
    ,[equality_columns] AS [EqualityColumns]
    ,[inequality_columns] AS [InequalityColumns]
    ,[included_columns] AS [IncludedColumns]
    ,[unique_compiles] AS [UniqueCompiles]
    ,[user_seeks] AS [UserSeeks]
    ,[user_scans] AS [UserScans]
    ,[avg_total_user_cost] AS [AvgTotalUserCost]
    ,[avg_user_impact] AS [AvgUserImpact]
    ,@last_service_start_date AS [LastServiceStartDate]
FROM [dbo].[MissingIndexStats]
ORDER BY [database_name], 
        --([avg_total_user_cost] * [avg_user_impact] * ([user_seeks]+[user_scans])) DESC, 
        [object_name];

SET @SQLCmd = '
IF OBJECT_ID(''dbo.[MissingIndexStats]'') IS NOT NULL
BEGIN
    DROP TABLE [dbo].[MissingIndexStats];
END';
EXEC sp_executesql @SQLCmd;
