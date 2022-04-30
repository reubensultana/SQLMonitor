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
    
	-- NOTE: the [IsAlive] column is a "fake" value used in the data set to determine if the server is avaialable or not
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
		,[SqlLoginSecret]
		,0 AS [IsAlive]
	FROM [dbo].[vwMonitoredServers] 
	WHERE [RecordStatus] = 'A' 
	AND [ServerDomain] LIKE @DomainName
	ORDER BY [ServerOrder] ASC, [ServerName] ASC;
END
GO
