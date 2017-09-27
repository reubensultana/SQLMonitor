USE [SQLMonitor]
GO

IF OBJECT_ID(N'[Reporting].[uspListServerLogins]') IS NOT NULL
DROP PROCEDURE [Reporting].[uspListServerLogins]
GO

CREATE PROCEDURE [Reporting].[uspListServerLogins] 
    @ServerName nvarchar(128) = '%',
    @RoleName nvarchar(128) = '%'
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON;
    SELECT [ServerName]
          ,[LoginName]
          ,[Type]
          ,[CreateDate]
          ,[ModifyDate]
          ,[PasswordLastSet]
          ,[DefaultDatabase]
          ,[DefaultLanguage]
          ,[IsDisabled]
          ,[IsPolicyChecked]
          ,[IsExpirationChecked]
          ,[sysadmin]
          ,[securityadmin]
          ,[serveradmin]
          ,[setupadmin]
          ,[processadmin]
          ,[diskadmin]
          ,[dbcreator]
          ,[bulkadmin]
          ,[SecurablesPermissions]
    FROM [SQLMonitor].[Monitor].[server_logins]
    WHERE [ServerName] LIKE @ServerName
    AND [RecordStatus] = 'A'
    AND (
        (CASE WHEN @RoleName = '%' THEN 1 END) = 1 OR
        [sysadmin] = (CASE WHEN @RoleName = 'sysadmin' THEN 1 END) OR
        [securityadmin] = (CASE WHEN @RoleName = 'securityadmin' THEN 1 END) OR
        [serveradmin] = (CASE WHEN @RoleName = 'serveradmin' THEN 1 END) OR
        [setupadmin] = (CASE WHEN @RoleName = 'setupadmin' THEN 1 END) OR
        [processadmin] = (CASE WHEN @RoleName = 'processadmin' THEN 1 END) OR
        [diskadmin] = (CASE WHEN @RoleName = 'diskadmin' THEN 1 END) OR
        [dbcreator] = (CASE WHEN @RoleName = 'dbcreator' THEN 1 END) OR
        [bulkadmin] = (CASE WHEN @RoleName = 'bulkadmin' THEN 1 END)
    )
    ORDER BY 
        CASE 
            WHEN [ServerName] LIKE 'CFS%' THEN 1 
            WHEN [ServerName] LIKE 'STG%' THEN 2 
            WHEN [ServerName] LIKE 'DEV%' THEN 3 
            ELSE 4 
        END, 
        [Type], [LoginName];
END
GO

-- EXEC [SQLMonitor].[Reporting].[uspListServerLogins] 


USE [master]
GO
