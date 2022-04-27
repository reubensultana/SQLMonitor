USE [SQLMonitor]
GO

IF OBJECT_ID('[dbo].[vwMonitoredServers]') IS NOT NULL
DROP VIEW [dbo].[vwMonitoredServers]
GO

CREATE VIEW [dbo].[vwMonitoredServers]
AS
SELECT 
    [ServerName]
    ,[ServerAlias]
    ,[ServerDescription]
    ,[ServerIpAddress]
    ,[SqlTcpPort]
    ,[ServerDomain]
    ,[ServerOrder]
    ,[SqlVersion]
    ,[SqlLoginName]
    ,[dbo].[udf_decryptvaluebycert] ([SqlLoginSecret], 'SQLServersMonitor') AS [SqlLoginSecret]
    ,[RecordStatus]
    ,[RecordCreated]
FROM [dbo].[MonitoredServers];
GO

USE [master]
GO


CREATE TRIGGER [dbo].[trgMonitoredServersE]
    ON [dbo].[vwMonitoredServers]
    INSTEAD OF INSERT, UPDATE
AS
SET NOCOUNT ON;

-- check for updates
IF EXISTS(SELECT * FROM deleted)
BEGIN
    UPDATE [dbo].[MonitoredServers]
    SET [ServerName]        = i.[ServerName]
        ,[ServerAlias]      = i.[ServerAlias]
        ,[ServerDescription] = i.[ServerDescription]
        ,[ServerIpAddress]  = i.[ServerIpAddress]
        ,[SqlTcpPort]       = i.[SqlTcpPort]
        ,[ServerDomain]     = i.[ServerDomain]
        ,[ServerOrder]      = i.[ServerOrder]
        ,[SqlVersion]       = i.[SqlVersion]
        ,[SqlLoginName]     = i.[SqlLoginName]
        ,[SqlLoginSecret]   = ENCRYPTBYCERT(CERT_ID('SQLServersMonitor'), i.[SqlLoginSecret])
        ,[RecordStatus]     = i.[RecordStatus]
        ,[RecordCreated]    = i.[RecordCreated]
    FROM inserted i
        INNER JOIN [dbo].[MonitoredServers] ms ON ms.[ServerName] = i.[ServerName];
END   
ELSE
-- inserts only
BEGIN
    INSERT INTO [dbo].[MonitoredServers] (
        [ServerName]
        ,[ServerAlias]
        ,[ServerDescription]
        ,[ServerIpAddress]
        ,[SqlTcpPort]
        ,[ServerDomain]
        ,[ServerOrder]
        ,[SqlVersion]
        ,[SqlLoginName]
        ,[SqlLoginSecret]
        ,[RecordStatus]
        ,[RecordCreated]
        )
    SELECT 
        i.[ServerName]
        ,i.[ServerAlias]
        ,i.[ServerDescription]
        ,i.[ServerIpAddress]
        ,i.[SqlTcpPort]
        ,i.[ServerDomain]
        ,i.[ServerOrder]
        ,i.[SqlVersion]
        ,i.[SqlLoginName]
        ,ENCRYPTBYCERT(CERT_ID('SQLServersMonitor'), i.[SqlLoginSecret])
        ,'A'
        ,SYSDATETIMEOFFSET()
    FROM inserted i
END

GO
