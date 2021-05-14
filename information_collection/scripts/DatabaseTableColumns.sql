-- Category: Databases - Database Objects
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @database_name nvarchar(128);
DECLARE @SQLcmd nvarchar(4000);

CREATE TABLE #server_databases_columns (
    [server_name] nvarchar(128),
    [table_catalog] nvarchar(128), 
    [table_schema] nvarchar(128), 
    [table_name] nvarchar(128), 
    [column_name] nvarchar(128), 
    [ordinal_position] int,
    [data_type] nvarchar(128), 
    [length/precision] nvarchar(128)
);

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
-- check if 
IF ((SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES) > 5000)
BEGIN
	PRINT ''More than 5,000 Tables have been found in ' + @database_name + N'. This database will be skipped.''
END
ELSE
BEGIN
    SELECT
        @@SERVERNAME AS [server_name],
        c.table_catalog, c.table_schema, c.table_name, c.column_name, c.ordinal_position,
        c.data_type,     
        [length/precision] =
             CASE data_type
                 WHEN ''char'' THEN (CASE ISNULL(c.character_maximum_length, 0) WHEN 0 THEN '''' WHEN -1 THEN ''MAX'' ELSE convert(varchar(10), c.character_maximum_length) END)
                 WHEN ''nchar'' THEN (CASE ISNULL(c.character_maximum_length, 0) WHEN 0 THEN '''' WHEN -1 THEN ''MAX'' ELSE convert(varchar(10), c.character_maximum_length) END)
                 WHEN ''varchar'' THEN (CASE ISNULL(c.character_maximum_length, 0) WHEN 0 THEN '''' WHEN -1 THEN ''MAX'' ELSE convert(varchar(10), c.character_maximum_length) END)
                 WHEN ''nvarchar'' THEN (CASE ISNULL(c.character_maximum_length, 0) WHEN 0 THEN '''' WHEN -1 THEN ''MAX'' ELSE convert(varchar(10), c.character_maximum_length) END)
                 WHEN ''numeric''  THEN (CASE ISNULL(c.numeric_precision, 0) WHEN 0 THEN '''' ELSE convert(varchar(10), numeric_precision) + '', '' + convert(varchar(10), c.numeric_scale) END)
                 WHEN ''decimal''  THEN (CASE ISNULL(c.numeric_precision, 0) WHEN 0 THEN '''' ELSE convert(varchar(10), numeric_precision) + '', '' + convert(varchar(10), c.numeric_scale) END)
                 Else ''''
             END 
    FROM INFORMATION_SCHEMA.COLUMNS c
        INNER JOIN INFORMATION_SCHEMA.TABLES t ON c.TABLE_CATALOG = t.TABLE_CATALOG AND c.TABLE_NAME = t.TABLE_NAME
    WHERE t.TABLE_TYPE = ''BASE TABLE''
    AND c.table_name NOT IN (''dtproperties'', ''sysconstraints'', ''syssegments'');
END
';

    INSERT INTO #server_databases_columns
        EXEC sp_executesql @SQLcmd;

FETCH NEXT FROM d1 INTO @database_name;
END
CLOSE d1
DEALLOCATE d1
 /* END: for each database */

-- return data
SELECT 
    [server_name]
    ,[table_catalog]
    ,[table_schema]
    ,[table_name]
    ,[column_name]
    ,[ordinal_position]
    ,[data_type]
    ,[length/precision]
FROM #server_databases_columns
ORDER BY [table_catalog], [table_schema], [table_name], [ordinal_position];
