-- Category: Databases - Database Objects
SET NOCOUNT ON;

DECLARE @TableSpaceUsed TABLE (
    [DatabaseName] [nvarchar](128) NOT NULL,
    [TableName] [nvarchar](128) NOT NULL, 
    [RowCount] [bigint] NOT NULL, 
    [ReservedKB] [bigint] NOT NULL, 
    [DataSizeKB] [bigint] NOT NULL,
    [IndexSizeKB] [bigint] NOT NULL,
    [UnusedSpaceKB] [bigint] NOT NULL
);

DECLARE @TableSpaceUsed_temp TABLE (
    [TableName] [nvarchar](128) NOT NULL, 
    [RowCount] [bigint] NOT NULL, 
    [ReservedKB] [bigint] NOT NULL, 
    [DataSizeKB] [bigint] NOT NULL,
    [IndexSizeKB] [bigint] NOT NULL,
    [UnusedSpaceKB] [bigint] NOT NULL
);

-- process info
DECLARE @database_name nvarchar(128);
DECLARE @SQLCmd nvarchar(2000);
SET @SQLCmd = N'';

/* START: for each database */
DECLARE d1 CURSOR FOR
    SELECT [name] FROM sys.databases 
    WHERE database_id > 4
    AND ([name] NOT LIKE N'AdventureWorks%') AND ([name] NOT LIKE N'DBAToolbox%') 
    AND ([name] NOT LIKE N'Northwind%') AND ([name] NOT LIKE N'pubs%') 
    AND ([name] NOT LIKE N'ReportServer%') AND ([name] NOT LIKE N'DQS_%')
    ORDER BY [name] ASC;
OPEN d1;
FETCH NEXT FROM d1 INTO @database_name;
WHILE (@@FETCH_STATUS = 0)
BEGIN
    SET @SQLCmd = N'
USE [' + @database_name + N'];
INSERT INTO [tempdb].[dbo].[TableSpaceUsed_temp]
SELECT 
    SCHEMA_NAME(sobj.schema_id) + ''.'' + sobj.name AS [TableName], 
    SUM(sptn.Rows) AS [RowCount],
    SUM(total_pages*8) AS [ReservedKB],
    SUM(data_pages*8) AS [DataSizeKB],
    SUM((used_pages-data_pages)*8) AS [IndexSizeKB],
    SUM((total_pages-used_pages)*8) AS [UnusedSpaceKB]
FROM sys.objects AS sobj
    INNER JOIN sys.partitions AS sptn ON sobj.object_id = sptn.object_id
    INNER JOIN sys.allocation_units sau ON sau.container_id = (
        CASE sau.type 
            WHEN 1 THEN sptn.hobt_id 
            WHEN 2 THEN sptn.partition_id 
            WHEN 3 THEN sptn.hobt_id 
        END
        )
WHERE sobj.type = ''U''
AND sobj.is_ms_shipped = 0x0
AND sptn.index_id < 2 -- 0:Heap, 1:Clustered
GROUP BY sobj.schema_id, sobj.name
ORDER BY [TableName];
';
	INSERT INTO @TableSpaceUsed_temp
    EXEC sp_executesql @SQLCmd;

    INSERT INTO @TableSpaceUsed
        SELECT
            @database_name, t1.[TableName],
            t1.[RowCount], t1.[ReservedKB], t1.[DataSizeKB], t1.[IndexSizeKB], t1.[UnusedSpaceKB]
        FROM @TableSpaceUsed_temp t1 
        ORDER BY t1.[TableName];

    DELETE FROM @TableSpaceUsed_temp;

    FETCH NEXT FROM d1 INTO @database_name;
END
CLOSE d1
DEALLOCATE d1
 /* END: for each database */

-- return data
SELECT
    CONVERT(nvarchar(128), SERVERPROPERTY('ServerName')) AS [ServerName],
    [DatabaseName],
    [TableName], 
    [RowCount], 
    [ReservedKB], 
    [DataSizeKB],
    [IndexSizeKB],
    [UnusedSpaceKB]
FROM @TableSpaceUsed
ORDER BY [DatabaseName], [TableName];
