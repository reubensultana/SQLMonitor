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
            SELECT 1 FROM [dbo].[MonitoredServers] WHERE [RecordStatus] = 'A'
            -- temporpermanent (?) fix due to incorrect server name in sys.servers
            AND COALESCE([ServerAlias], [ServerName]) = @ServerName
            )
        )
    BEGIN
        SELECT sfs.[ServerName]
              ,sfs.[Drive]
              ,sfs.[FreeMB]
              ,sfs.[RecordCreated]
        FROM [Archive].[ServerFreeSpace] sfs
            INNER JOIN [dbo].[MonitoredServers] ms ON COALESCE(ms.[ServerAlias], ms.[ServerName]) = sfs.[ServerName]
        -- temporpermanent (?) fix due to incorrect server name in sys.servers
        WHERE COALESCE(ms.[ServerAlias], ms.[ServerName]) = @ServerName
        AND sfs.[Drive] LIKE @DriveLetter
        AND @IncludeArchive = 1 -- depends on input parameter (functions as an "if" or "case" statement)

        UNION ALL

        SELECT sfs.[ServerName]
              ,sfs.[Drive]
              ,sfs.[FreeMB]
              ,sfs.[RecordCreated]
        FROM [Monitor].[ServerFreeSpace] sfs
            INNER JOIN [dbo].[MonitoredServers] ms ON COALESCE(ms.[ServerAlias], ms.[ServerName]) = sfs.[ServerName]
        -- temporpermanent (?) fix due to incorrect server name in sys.servers
        WHERE COALESCE(ms.[ServerAlias], ms.[ServerName]) = @ServerName
        AND sfs.[Drive] LIKE @DriveLetter
    END
END
GO
