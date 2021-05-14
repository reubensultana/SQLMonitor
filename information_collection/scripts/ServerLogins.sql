-- Category: Database Engine Security
SET NOCOUNT ON;

SELECT 
    [ServerName], [LoginName], [Type], [CreateDate], [ModifyDate], 
    CONVERT(datetime, LOGINPROPERTY([LoginName], 'PasswordLastSetTime')) AS [PasswordLastSet],
    [DefaultDatabase], [DefaultLanguage], [IsDisabled], [IsPolicyChecked], [IsExpirationChecked], 
    SUM([sysadmin]) AS [sysadmin], SUM([securityadmin]) AS [securityadmin], SUM([serveradmin]) AS [serveradmin], SUM([setupadmin]) AS [setupadmin], 
    SUM([processadmin]) AS [processadmin], SUM([diskadmin]) AS [diskadmin], SUM([dbcreator]) AS [dbcreator], SUM([bulkadmin]) AS [bulkadmin],
    COALESCE(d.[permission_name], '') AS [SecurablesPermissions]
FROM (
    SELECT 
        CONVERT(nvarchar(128), SERVERPROPERTY('ServerName')) AS [ServerName],
        sp.[sid] AS [sid],
        sp.[name] AS [LoginName],
        sp.[type_desc] AS [Type],
        CONVERT(datetime, sp.[create_date]) AS [CreateDate],
        CONVERT(datetime, sp.[modify_date]) AS [ModifyDate],
        COALESCE(sp.[default_database_name], '') AS [DefaultDatabase],
        COALESCE(sp.[default_language_name], '') AS [DefaultLanguage],
        sp.[is_disabled] AS [IsDisabled],
        COALESCE(sl.[is_policy_checked], 0) AS [IsPolicyChecked],
        COALESCE(sl.[is_expiration_checked], 0) AS [IsExpirationChecked],
        CASE COALESCE(SUSER_NAME([srm].[role_principal_id]), '') WHEN 'sysadmin' THEN 1 ELSE 0 END AS [sysadmin], 
        CASE COALESCE(SUSER_NAME([srm].[role_principal_id]), '') WHEN 'securityadmin' THEN 1 ELSE 0 END AS [securityadmin], 
        CASE COALESCE(SUSER_NAME([srm].[role_principal_id]), '') WHEN 'serveradmin' THEN 1 ELSE 0 END AS [serveradmin], 
        CASE COALESCE(SUSER_NAME([srm].[role_principal_id]), '') WHEN 'setupadmin' THEN 1 ELSE 0 END AS [setupadmin], 
        CASE COALESCE(SUSER_NAME([srm].[role_principal_id]), '') WHEN 'processadmin' THEN 1 ELSE 0 END AS [processadmin], 
        CASE COALESCE(SUSER_NAME([srm].[role_principal_id]), '') WHEN 'diskadmin' THEN 1 ELSE 0 END AS [diskadmin], 
        CASE COALESCE(SUSER_NAME([srm].[role_principal_id]), '') WHEN 'dbcreator' THEN 1 ELSE 0 END AS [dbcreator], 
        CASE COALESCE(SUSER_NAME([srm].[role_principal_id]), '') WHEN 'bulkadmin' THEN 1 ELSE 0 END AS [bulkadmin]
    FROM [sys].[server_principals] sp
        LEFT JOIN [sys].[sql_logins] sl ON sp.[sid] = sl.[sid]
        LEFT JOIN [sys].[server_role_members] srm ON sp.[principal_id] = srm.[member_principal_id] 
    WHERE sp.[type] LIKE '[GSU]'
) a
    CROSS APPLY ( 
        SELECT STUFF( 
            (SELECT N',' + [srvperm].[permission_name] + N' (' + [srvperm].[class_desc] + (
                CASE [srvperm].[class_desc] 
                    WHEN N'SERVER' THEN N''
                    WHEN N'ENDPOINT' THEN N' ' + (SELECT CONVERT(nvarchar(10), port) FROM sys.tcp_endpoints WHERE endpoint_id >= 65536 AND endpoint_id = srvperm.major_id)
                    ELSE N''
                END
                ) + N')'
            FROM [sys].[server_permissions] srvperm
                INNER JOIN [sys].[server_principals] srvprin ON [srvperm].[grantee_principal_id] = [srvprin].[principal_id]
            WHERE [srvprin].sid = a.sid
            AND [srvperm].[permission_name] <> 'CONNECT SQL'
            ORDER BY srvprin.[name], srvperm.class, [permission_name]
            FOR XML PATH(''), TYPE).value('.', 'varchar(max)')
           ,1,1,'')
        ) D ( [permission_name] )

GROUP BY [ServerName], [LoginName], [Type], [CreateDate], [ModifyDate], [DefaultDatabase], [DefaultLanguage], [IsDisabled], [IsPolicyChecked], [IsExpirationChecked], d.[permission_name]
ORDER BY [Type], [LoginName];
