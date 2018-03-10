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
            SELECT 1 FROM [dbo].[MonitoredServers] WHERE [RecordStatus] = 'A'
            -- temporpermanent (?) fix due to incorrect server name in sys.servers
            AND COALESCE([ServerAlias], [ServerName]) = @ServerName
            )
        )
    BEGIN
        SELECT '***** Select All ***** ' AS [DriveLetter], '%' AS [DriveLetterValue], 0 AS [LetterOrder]
        UNION ALL
        SELECT DISTINCT sfs.[Drive], sfs.[Drive], 1
        FROM [Monitor].[ServerFreeSpace] sfs
            INNER JOIN [dbo].[MonitoredServers] ms ON COALESCE(ms.[ServerAlias], ms.[ServerName]) = sfs.[ServerName]
        -- temporpermanent (?) fix due to incorrect server name in sys.servers
        WHERE COALESCE(ms.[ServerAlias], ms.[ServerName]) = @ServerName
        ORDER BY [LetterOrder], [DriveLetter] ASC
    END
END
GO


USE [master]
GO
