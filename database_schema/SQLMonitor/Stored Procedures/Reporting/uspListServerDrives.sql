USE [SQLMonitor]
GO

IF OBJECT_ID(N'[Reporting].[uspListServerDrives]') IS NOT NULL
DROP PROCEDURE [Reporting].[uspListServerDrives]
GO

CREATE PROCEDURE [Reporting].[uspListServerDrives] 
    @ServerName nvarchar(128) = ''
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON;

    IF ((COALESCE(@ServerName, NULLIF(LTRIM(RTRIM(@ServerName)), '')) IS NOT NULL) 
        AND EXISTS(
            SELECT 1 FROM [dbo].[MonitoredServers] WHERE [RecordStatus] = 'A' --AND [ServerName]=@ServerName
            -- temporpermanent (?) fix due to incorrect server name in sys.servers on CFSDGLPEGSQL01-PROD
            AND [ServerName]=(CASE @ServerName WHEN 'CFSDGLPEGSQL01-' THEN 'CFSDGLPEGSQL01-PROD' ELSE @ServerName END))
        )
    BEGIN
        SELECT '***** Select All ***** ' AS [DriveLetter], '%' AS [DriveLetterValue], 0 AS [LetterOrder]
        UNION ALL
        SELECT DISTINCT [Drive], [Drive], 1
        FROM [Monitor].[ServerFreeSpace]
        WHERE [ServerName]=@ServerName 
        ORDER BY [LetterOrder], [DriveLetter] ASC
    END
END
GO

-- EXEC [SQLMonitor].[Reporting].[uspListServerDrives] @ServerName='CFSDGLPEGSQL01-'


USE [master]
GO
