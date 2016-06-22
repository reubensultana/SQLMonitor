USE [SQLMonitor]
GO

IF OBJECT_ID('[Monitor].[server_logins]') IS NOT NULL
DROP VIEW [Monitor].[server_logins]
GO

CREATE VIEW [Monitor].[server_logins]
AS
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
        ,[RecordStatus]
        ,[RecordCreated]
FROM [Monitor].[ServerLogins]
--WHERE [RecordStatus] = 'A'
GO
