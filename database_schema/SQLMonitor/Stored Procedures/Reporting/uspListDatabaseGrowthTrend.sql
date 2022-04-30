IF OBJECT_ID(N'[Reporting].[uspListDatabaseGrowthTrend]') IS NOT NULL
DROP PROCEDURE [Reporting].[uspListDatabaseGrowthTrend]
GO

CREATE PROCEDURE [Reporting].[uspListDatabaseGrowthTrend] 
    @ServerName nvarchar(128) = '',
    @DatabaseName nvarchar(128) = '',
    @IncludeArchive bit = 0,
    @ArchiveMonths smallint = 6,
    @IncludeSystem bit = 1
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON;

    DECLARE @ExcludedDatabases TABLE ([database_name] nvarchar(128));
    INSERT INTO @ExcludedDatabases VALUES ('master'), ('model'), ('msdb'), ('tempdb'), ('DBAToolbox'), ('SSISDB');

    IF ((COALESCE(@ServerName, NULLIF(LTRIM(RTRIM(@ServerName)), '')) IS NOT NULL) AND
        (COALESCE(@DatabaseName, NULLIF(LTRIM(RTRIM(@DatabaseName)), '')) IS NOT NULL)
        -- and server name value is valid
        AND EXISTS(
            SELECT 1 FROM [dbo].[MonitoredServers] WHERE [RecordStatus] = 'A' 
            -- temporpermanent (?) fix due to incorrect server name in sys.servers 
            AND COALESCE([ServerAlias], [ServerName]) = @ServerName
            )
        )
    BEGIN
        WITH cteExcludedDatabases 
        AS (
            SELECT [database_name] FROM @ExcludedDatabases

            UNION ALL

            SELECT DISTINCT dc.[DatabaseName]
            FROM [Archive].[DatabaseConfigurations] dc
                INNER JOIN [dbo].[MonitoredServers] ms ON COALESCE(ms.[ServerAlias], ms.[ServerName]) = dc.[ServerName]
            -- temporpermanent (?) fix due to incorrect server name in sys.servers 
            WHERE COALESCE(ms.[ServerAlias], ms.[ServerName]) = @ServerName
            AND @IncludeArchive = 1 -- depends on input parameter
            AND dc.[RecordCreated] >= DATEADD(M, -@ArchiveMonths, CURRENT_TIMESTAMP)
            AND ((dc.[DatabaseName] LIKE 'AdventureWorks%') OR (dc.[DatabaseName] LIKE 'ReportServer%'))

            UNION ALL

            SELECT DISTINCT dc.[DatabaseName]
            FROM [Monitor].[DatabaseConfigurations] dc
                INNER JOIN [dbo].[MonitoredServers] ms ON COALESCE(ms.[ServerAlias], ms.[ServerName]) = dc.[ServerName]
            -- temporpermanent (?) fix due to incorrect server name in sys.servers 
            WHERE COALESCE(ms.[ServerAlias], ms.[ServerName]) = @ServerName
            AND ((dc.[DatabaseName] LIKE 'AdventureWorks%') OR (dc.[DatabaseName] LIKE 'ReportServer%'))

        ),
        cteGrowthTrendArchive 
        AS (
            SELECT ms.[ServerName], dc.[DatabaseName], SUM(dc.[SizeMB]) AS [SizeMB], CAST(dc.[RecordCreated] AS date) AS [RecordCreated]
            FROM [Archive].[DatabaseConfigurations] dc
                INNER JOIN [dbo].[MonitoredServers] ms ON COALESCE(ms.[ServerAlias], ms.[ServerName]) = dc.[ServerName]
            -- temporpermanent (?) fix due to incorrect server name in sys.servers 
            WHERE COALESCE(ms.[ServerAlias], ms.[ServerName]) = @ServerName
            --AND dc.[DatabaseName] LIKE @DatabaseName
            AND dc.[FileType] IN ('FILESTREAM', 'ROWS') -- total for data files only
            AND @IncludeArchive = 1 -- depends on input parameter
            AND dc.[RecordCreated] >= DATEADD(M, -@ArchiveMonths, CURRENT_TIMESTAMP)
            GROUP BY ms.[ServerName], dc.[DatabaseName], dc.[RecordCreated]
        ),
        cteGrowthTrend 
        AS (
            SELECT ms.[ServerName], dc.[DatabaseName], SUM(dc.[SizeMB]) AS [SizeMB], CAST(dc.[RecordCreated] AS date) AS [RecordCreated]
            FROM [Monitor].[DatabaseConfigurations] dc
                INNER JOIN [dbo].[MonitoredServers] ms ON COALESCE(ms.[ServerAlias], ms.[ServerName]) = dc.[ServerName]
            -- temporpermanent (?) fix due to incorrect server name in sys.servers 
            WHERE COALESCE(ms.[ServerAlias], ms.[ServerName]) = @ServerName
            AND dc.[FileType] IN ('FILESTREAM', 'ROWS') -- total for data files only
            GROUP BY ms.[ServerName], dc.[DatabaseName], dc.[RecordCreated]
        )
        -- archive
        SELECT [ServerName], [DatabaseName], [SizeMB], [RecordCreated]
        FROM cteGrowthTrendArchive
        WHERE [DatabaseName] LIKE @DatabaseName
        -- exclude system databases from initial filter
        AND ([DatabaseName] NOT IN (SELECT [database_name] FROM cteExcludedDatabases))
        
        UNION ALL

        SELECT [ServerName], [DatabaseName], [SizeMB], [RecordCreated]
        FROM cteGrowthTrendArchive
        WHERE (@IncludeSystem = 1) -- include system databases
        -- include system databases in initial filter
        AND ([DatabaseName] IN (SELECT [database_name] FROM cteExcludedDatabases))
        -- end of archive bit
        
        UNION ALL

        -- main data set
        SELECT [ServerName], [DatabaseName], [SizeMB], [RecordCreated]
        FROM cteGrowthTrend
        WHERE [DatabaseName] LIKE @DatabaseName
        -- exclude system databases from initial filter
        AND ([DatabaseName] NOT IN (SELECT [database_name] FROM cteExcludedDatabases))

        UNION ALL

        SELECT [ServerName], [DatabaseName], [SizeMB], [RecordCreated]
        FROM cteGrowthTrend
        WHERE (@IncludeSystem = 1) -- include system databases
        AND ([DatabaseName] IN (SELECT [database_name] FROM cteExcludedDatabases))
        -- end of main data set

        ORDER BY [ServerName], [DatabaseName], [RecordCreated];
    END
END
GO

/*
USE [SQLMonitor]
GO
CREATE NONCLUSTERED INDEX [<Name of Missing Index, sysname,>]
    ON [Archive].[DatabaseConfigurations] ([ServerName],[DatabaseName])
GO
*/
