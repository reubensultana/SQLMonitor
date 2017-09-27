USE [SQLMonitor]
GO

IF OBJECT_ID(N'[dbo].[uspGetServers]') IS NOT NULL
DROP PROCEDURE [dbo].[uspGetServers]
GO

CREATE PROCEDURE [dbo].[uspGetServers] 
	@DomainName nvarchar(15) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

    -- get the domain name for the login running the stored procedure
	IF (NULLIF(@DomainName, '') IS NULL)
		SET @DomainName = SUBSTRING(SYSTEM_USER, 1, CHARINDEX('\', SYSTEM_USER, 1)-1);
    
    SELECT ServerName, SqlTcpPort FROM [dbo].[MonitoredServers] 
	WHERE [RecordStatus] = 'A' 
	AND [ServerDomain] LIKE @DomainName
	ORDER BY [ServerOrder], 
        CASE 
            WHEN [ServerName] LIKE 'CFS%' THEN 1 
            WHEN [ServerName] LIKE 'STG%' THEN 2 
            WHEN [ServerName] LIKE 'DEV%' THEN 3 
            ELSE 4 
        END;
END
GO


USE [master]
GO
