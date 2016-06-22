-- Category: Databases Configuration
SET NOCOUNT ON;

SELECT 
    CONVERT(nvarchar(128), SERVERPROPERTY('ServerName')) AS ServerName,
    DB_NAME(database_id) AS [DatabaseName],
    [file_id] AS [FileID], 
    [type_desc] AS [FileType], 
    [name] AS [FileName], 
    [physical_name] AS [FilePath], 
    [state_desc] AS [State], 
    [is_read_only] AS [IsReadOnly], 
    CAST(((CAST([size] AS numeric(15,4))*8)/1024) AS numeric(15,2)) AS [SizeMB], 
    CASE 
        WHEN [max_size] = 0 THEN 0
        WHEN [max_size] = -1 THEN -1
        ELSE CAST(((CAST([max_size] AS numeric(15,0))*8)/1024) AS numeric(15,0))
    END AS [MaxSizeMB], 
    CASE [is_percent_growth]
        WHEN 1 THEN [growth] 
        ELSE CAST(((CAST([growth] AS numeric(15,0))*8)/1024) AS numeric(15,0))
    END AS [GrowthMB], 
    [is_percent_growth] AS [IsPercentGrowth]
FROM sys.master_files
ORDER BY [database_id] ASC, [file_id] ASC, [name] ASC;
