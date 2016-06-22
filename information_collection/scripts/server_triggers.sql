-- Category: Database Engine Configuration
SET NOCOUNT ON;

SELECT 
    CONVERT(nvarchar(128), SERVERPROPERTY('ServerName')) AS ServerName
    ,[name] AS [ObjectName]
    ,[type_desc] AS [ObjectType]
    ,CAST([create_date] AS datetime2(0)) AS [CreateDate]
    ,CAST([modify_date] AS datetime2(0)) AS [ModifyDate]
    ,is_disabled AS [IsDisabled]
FROM sys.server_triggers
ORDER BY [name] ASC;
