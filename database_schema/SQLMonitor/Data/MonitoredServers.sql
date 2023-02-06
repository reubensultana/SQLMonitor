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
     (N'Server01', NULL, '', '10.11.12.10', 'CORP', 1433, 5, 12.00, 'SqlMonitor', 'P@ssw0rd1!', 'A')
    ,(N'Server02', NULL, '', '10.11.12.11', 'CORP', 1433, 5, 12.00, 'SqlMonitor', 'P@ssw0rd2!', 'A')
    ,(N'Server03', NULL, '', '10.11.12.12', 'CORP', 1433, 5, 12.00, 'SqlMonitor', 'P@ssw0rd3!', 'A')
    ,(N'Server04', NULL, '', '10.11.12.13', 'CORP', 1433, 5, 12.00, 'SqlMonitor', 'P@ssw0rd4!', 'A')
    ,(N'Server05', NULL, '', '10.11.12.14', 'CORP', 1433, 5, 12.00, 'SqlMonitor', 'P@ssw0rd5!', 'A')
    ,(N'Server06', NULL, '', '10.11.12.15', 'CORP', 1433, 5, 12.00, 'SqlMonitor', 'P@ssw0rd6!', 'A')
    ,(N'Server07', NULL, '', '10.11.12.16', 'CORP', 1433, 5, 12.00, 'SqlMonitor', 'P@ssw0rd7!', 'A')

GO

-- SELECT * FROM [dbo].[MonitoredServers] ORDER BY ServerOrder, ServerName
