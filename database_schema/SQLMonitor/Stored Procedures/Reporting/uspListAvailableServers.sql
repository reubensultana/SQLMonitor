USE [SQLMonitor]
GO

IF OBJECT_ID(N'[Reporting].[uspListAvailableServers]') IS NOT NULL
DROP PROCEDURE [Reporting].[uspListAvailableServers]
GO

CREATE PROCEDURE [Reporting].[uspListAvailableServers] 
	@DomainName nvarchar(15) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

    -- get the domain name for the login running the stored procedure
	IF (NULLIF(@DomainName, '') IS NULL)
		SET @DomainName = SUBSTRING(SYSTEM_USER, 1, CHARINDEX('\', SYSTEM_USER, 1)-1);

    WITH cteServerList AS (
        SELECT '***** Select All ***** ' AS [ServerName], '%' AS [ServerNameValue], NULL AS [ServerOrder]
        UNION ALL
        SELECT 
            [ServerName], 
            -- temporpermanent (?) fix due to incorrect server name in sys.servers 
			COALESCE([ServerAlias], [ServerName]) AS [ServerNameValue],
            [ServerOrder]
        FROM [dbo].[MonitoredServers]
        WHERE ([RecordStatus] = 'A'
        AND [ServerDomain] LIKE @DomainName)
    )
    SELECT [ServerName], [ServerNameValue], [ServerOrder]
    FROM cteServerList
    ORDER BY [ServerOrder], [ServerName];
END
GO

-- EXEC [SQLMonitor].[Reporting].[uspListAvailableServers] 


USE [master]
GO
