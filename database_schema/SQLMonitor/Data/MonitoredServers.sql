SET NOCOUNT ON;

/* ----- dbo.MonitoredServers ----- */
/*
SET NOCOUNT ON;
SELECT ',(N''' + ServerName + ''', ' + COALESCE('''' + ServerAlias + '''', 'NULL') + ', ''' + ServerDescription + ''', ''' + 
    ServerIpAddress + ''', ''' + ServerDomain + ''', ' + CAST(SqlTcpPort AS varchar(10)) + ', ' + CAST(ServerOrder as varchar(10)) + ', ' + 
    CAST(SqlVersion AS varchar(10)) + ', ''' + SqlLoginName + ''', ''' + SqlLoginSecret + ''', ''' + RecordStatus + ''')'
FROM [SQLMonitor].[dbo].[vwMonitoredServers]
ORDER BY ServerOrder, ServerName
*/

-- TRUNCATE TABLE [dbo].[MonitoredServers];
INSERT INTO [dbo].[vwMonitoredServers] (
    ServerName, ServerAlias, ServerDescription, ServerIpAddress, ServerDomain, SqlTcpPort, 
    ServerOrder, SqlVersion, SqlLoginName, SqlLoginSecret, RecordStatus )
VALUES 
     (N'SRVR01', NULL, '', '10.11.12.10', 'CONTOSO', 1433, 5, 12.00, 'SqlMonitor', 'P@ssw0rd1!', 'A')
    ,(N'SRVR02', NULL, '', '10.11.12.11', 'CONTOSO', 1433, 5, 12.00, 'SqlMonitor', 'P@ssw0rd1!', 'A')
    ,(N'SRVR03', NULL, '', '10.11.12.12', 'CONTOSO', 1433, 5, 12.00, 'SqlMonitor', 'P@ssw0rd1!', 'A')
    ,(N'SRVR04', NULL, '', '10.11.12.13', 'CONTOSO', 1433, 5, 12.00, 'SqlMonitor', 'P@ssw0rd1!', 'A')
    ,(N'SRVR05', NULL, '', '10.11.12.14', 'CONTOSO', 1433, 5, 12.00, 'SqlMonitor', 'P@ssw0rd1!', 'A')
    ,(N'SRVR06', NULL, '', '10.11.12.15', 'CONTOSO', 1433, 5, 12.00, 'SqlMonitor', 'P@ssw0rd1!', 'A')
    ,(N'SRVR07', NULL, '', '10.11.12.16', 'CONTOSO', 1433, 5, 12.00, 'SqlMonitor', 'P@ssw0rd1!', 'A')

GO

-- SELECT * FROM [dbo].[MonitoredServers] ORDER BY ServerOrder, ServerName
