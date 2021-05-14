-- Category: Database Security
SET NOCOUNT ON;

DECLARE @DatabaseName nvarchar(128);
DECLARE @DatabaseList CURSOR;
DECLARE @SQLcmd nvarchar(4000);

CREATE TABLE #DatabasePermissions (
    [database_id] int,
    [database_name] nvarchar(128),
    [database_principal] nvarchar(128),
    [permission_name] nvarchar(200)
);

CREATE TABLE #DatabaseRoleMembership (
    [database_id] int,
    [database_name] nvarchar(128),
    [member_name] nvarchar(128),
    [database_role] nvarchar(128)
);

SET @DatabaseList = CURSOR READ_ONLY FOR
    SELECT [name] FROM sys.databases 
    WHERE database_id > 4
    AND ([name] NOT LIKE N'AdventureWorks%') AND ([name] NOT LIKE N'DBAToolbox%') 
    AND ([name] NOT LIKE N'Northwind%') AND ([name] NOT LIKE N'pubs%') 
    --AND ([name] NOT LIKE N'ReportServer%') 
    AND ([name] NOT LIKE N'DQS_%')
OPEN @DatabaseList
FETCH NEXT FROM @DatabaseList INTO @DatabaseName
WHILE (@@FETCH_STATUS = 0)
BEGIN
    SET @SQLcmd = N'';
    -- database permissions
    SET @SQLcmd = N'
USE ' + QUOTENAME(@DatabaseName, '[') + ';
SELECT DISTINCT
    DB_ID(DB_NAME()) AS [database_id] ,
    DB_NAME() AS [database_name],
    [prin].[name] [database_principal], 
    [sec].[state_desc] + '' '' + [sec].[permission_name] [permission_name]
FROM [sys].[database_permissions] [sec]
    INNER JOIN [sys].[database_principals] [prin] ON [sec].[grantee_principal_id] = [prin].[principal_id]
WHERE [sec].[class] IN (0, 1)
ORDER BY [database_principal], [permission_name];
';
    INSERT INTO #DatabasePermissions
        EXEC sp_executesql @SQLcmd;

    SET @SQLcmd = N'';
    -- membership in and permissions of database roles
    SET @SQLcmd = N'
USE ' + QUOTENAME(@DatabaseName, '[') + ';
IF EXISTS(
    SELECT 1
    FROM [sys].[database_role_members] [m]
        INNER JOIN [sys].[database_principals] [u] ON [u].[principal_id] = [m].[member_principal_id]
        INNER JOIN [sys].[database_principals] [g] ON [g].[principal_id] = [m].[role_principal_id]
    WHERE [u].[name] <> ''dbo''
    )
BEGIN
    SELECT 
        DB_ID(DB_NAME()) AS [database_id],
        DB_NAME() AS [database_name],
        [u].[name] [member_name],
        [g].[name] [database_role]
    FROM [sys].[database_role_members] [m]
        INNER JOIN [sys].[database_principals] [u] ON [u].[principal_id] = [m].[member_principal_id]
        INNER JOIN [sys].[database_principals] [g] ON [g].[principal_id] = [m].[role_principal_id]
    WHERE [u].[name] <> ''dbo''
    ORDER BY [member_name], [database_role];
END
';
    INSERT INTO #DatabaseRoleMembership
        EXEC sp_executesql @SQLcmd;

    FETCH NEXT FROM @DatabaseList INTO @DatabaseName
END
CLOSE @DatabaseList;
DEALLOCATE @DatabaseList;

-- return data
SELECT 
    CONVERT(nvarchar(128), SERVERPROPERTY('ServerName')) as [ServerName],
    a.[database_name] AS [DatabaseName], 
    a.[member_name] AS [PrincipalName],
    SUM([db_accessadmin]) AS [db_accessadmin],
    SUM([db_backupoperator]) AS [db_backupoperator],
    SUM([db_ddladmin]) AS [db_ddladmin],
    SUM([db_owner]) AS [db_owner],
    SUM([db_securityadmin]) AS [db_securityadmin],
    COALESCE(d.[permission_name], '') AS [SecurablesPermissions]
FROM (
    SELECT [database_id], [database_name], [member_name],
        CASE [database_role] WHEN 'db_accessadmin' THEN 1 ELSE 0 END AS [db_accessadmin],
        CASE [database_role] WHEN 'db_backupoperator' THEN 1 ELSE 0 END AS [db_backupoperator],
        CASE [database_role] WHEN 'db_ddladmin' THEN 1 ELSE 0 END AS [db_ddladmin],
        CASE [database_role] WHEN 'db_owner' THEN 1 ELSE 0 END AS [db_owner],
        CASE [database_role] WHEN 'db_securityadmin' THEN 1 ELSE 0 END AS [db_securityadmin]
    FROM #DatabaseRoleMembership
) a
    CROSS APPLY (
        SELECT STUFF (
            (SELECT N',' + [permission_name] 
            FROM #DatabasePermissions
            WHERE ([database_name] = a.[database_name] AND [database_principal] = a.[member_name])
            AND [permission_name] NOT IN (
                'GRANT CONNECT', 'GRANT DELETE', 'GRANT EXECUTE', 'GRANT INSERT', 'GRANT REFERENCES', 
                'GRANT SELECT', 'GRANT UPDATE', 'GRANT VIEW DEFINITION'
                )
            ORDER BY [database_principal], [permission_name]
            FOR XML PATH(''), TYPE).value('.', 'varchar(max)')
           ,1,1,'')
        ) D ( [permission_name] )
WHERE a.[member_name] <> 'guest'
GROUP BY a.[database_name], a.[member_name], d.[permission_name]
ORDER BY a.[database_name], a.[member_name];

-- clean up
DROP TABLE #DatabasePermissions;
DROP TABLE #DatabaseRoleMembership;
