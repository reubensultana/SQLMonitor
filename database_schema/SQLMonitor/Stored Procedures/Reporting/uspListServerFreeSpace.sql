USE [SQLMonitor]
GO

IF OBJECT_ID(N'[Reporting].[uspListServerFreeSpaceTrend]') IS NOT NULL
DROP PROCEDURE [Reporting].[uspListServerFreeSpaceTrend]
GO

CREATE PROCEDURE [Reporting].[uspListServerFreeSpaceTrend] 
    @ServerName nvarchar(128) = '',
    @DriveLetter char(1) = '%',
    @IncludeArchive bit = 0
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
        SELECT [ServerName]
              ,[Drive]
              ,[FreeMB]
              ,[RecordCreated]
        FROM [Archive].[ServerFreeSpace]
        -- WHERE [ServerName] = @ServerName
        -- temporpermanent (?) fix due to incorrect server name in sys.servers on CFSDGLPEGSQL01-PROD
        WHERE [ServerName]=(CASE @ServerName WHEN 'CFSDGLPEGSQL01-PROD' THEN 'CFSDGLPEGSQL01-' ELSE @ServerName END)
        AND [Drive] LIKE @DriveLetter
        AND @IncludeArchive = 1 -- depends on input parameter

        UNION ALL

        SELECT [ServerName]
              ,[Drive]
              ,[FreeMB]
              ,[RecordCreated]
        FROM [Monitor].[ServerFreeSpace]
        --WHERE [ServerName] = @ServerName
        -- temporpermanent (?) fix due to incorrect server name in sys.servers on CFSDGLPEGSQL01-PROD
        WHERE [ServerName]=(CASE @ServerName WHEN 'CFSDGLPEGSQL01-PROD' THEN 'CFSDGLPEGSQL01-' ELSE @ServerName END)
        AND [Drive] LIKE @DriveLetter
    END
END
GO

-- EXEC [SQLMonitor].[Reporting].[uspListServerFreeSpaceTrend] @ServerName='CFSDGLPEGSQL01-PROD', @DriveLetter='S'
-- EXEC [SQLMonitor].[Reporting].[uspListServerFreeSpaceTrend] @ServerName='CFSDGLPEGSQL01-PROD', @DriveLetter='S', @IncludeArchive=1
-- EXEC [SQLMonitor].[Reporting].[uspListServerFreeSpaceTrend] @ServerName='CFSDGLPEGSQL01-PROD', @IncludeArchive=1


USE [master]
GO
