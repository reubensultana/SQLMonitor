USE [SQLMonitor]
GO

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

    IF ((COALESCE(@ServerName, NULLIF(LTRIM(RTRIM(@ServerName)), '')) IS NOT NULL) AND
        (COALESCE(@DatabaseName, NULLIF(LTRIM(RTRIM(@DatabaseName)), '')) IS NOT NULL)
        -- and server name value is valid
        AND EXISTS(
            SELECT 1 FROM [dbo].[MonitoredServers] WHERE [RecordStatus] = 'A' 
            -- temporpermanent (?) fix due to incorrect server name in sys.servers 
            AND COALESCE([ServerAlias], [ServerName]) = @ServerName
            )
        -- and database name value is valid
        AND EXISTS(
            SELECT 1 FROM [Monitor].[ServerDatabases] sd
                INNER JOIN [dbo].[MonitoredServers] ms ON COALESCE(ms.[ServerAlias], ms.[ServerName]) = sd.[ServerName]
            WHERE sd.[RecordStatus] = 'A' AND ms.[RecordStatus] = 'A'
            -- temporpermanent (?) fix due to incorrect server name in sys.servers 
            AND COALESCE(ms.[ServerAlias], ms.[ServerName]) = @ServerName
            AND sd.[DatabaseName] LIKE @DatabaseName
            -- exclude system databases from initial filter
            AND ((sd.[DatabaseName] NOT IN ('master', 'model', 'msdb', 'tempdb', 'DBAToolbox', 'SSISDB')) AND
                 (sd.[DatabaseName] NOT LIKE 'AdventureWorks%') AND
                 (sd.[DatabaseName] NOT LIKE 'ReportServer%')
                )
            UNION ALL
            SELECT 1 FROM [Monitor].[ServerDatabases] sd
                INNER JOIN [dbo].[MonitoredServers] ms ON COALESCE(ms.[ServerAlias], ms.[ServerName]) = sd.[ServerName]
            WHERE sd.[RecordStatus] = 'A' AND ms.[RecordStatus] = 'A'
            -- temporpermanent (?) fix due to incorrect server name in sys.servers 
            AND COALESCE(ms.[ServerAlias], ms.[ServerName]) = @ServerName
            --AND sd.[DatabaseName] LIKE @DatabaseName
            -- limit this part to system databases only
            AND ((sd.[DatabaseName] IN ('master', 'model', 'msdb', 'tempdb', 'DBAToolbox', 'SSISDB')) OR
                 (sd.[DatabaseName] LIKE 'AdventureWorks%') OR
                 (sd.[DatabaseName] LIKE 'ReportServer%'))
            AND (@IncludeSystem = 1) -- include system databases
            )
        )
    BEGIN
        -- archive
        SELECT ms.[ServerName], dc.[DatabaseName], SUM(dc.[SizeMB]) AS [SizeMB], CAST(dc.[RecordCreated] AS date) AS [RecordCreated]
        FROM [Archive].[DatabaseConfigurations] dc
            INNER JOIN [dbo].[MonitoredServers] ms ON COALESCE(ms.[ServerAlias], ms.[ServerName]) = dc.[ServerName]
        -- temporpermanent (?) fix due to incorrect server name in sys.servers 
        WHERE COALESCE(ms.[ServerAlias], ms.[ServerName]) = @ServerName
        AND dc.[DatabaseName] LIKE @DatabaseName
        AND dc.[FileType] IN ('FILESTREAM', 'ROWS') -- total for data files only
        AND @IncludeArchive = 1 -- depends on input parameter
        AND dc.[RecordCreated] >= DATEADD(M, -@ArchiveMonths, CURRENT_TIMESTAMP)
        -- exclude system databases from initial filter
        AND ((dc.[DatabaseName] NOT IN ('master', 'model', 'msdb', 'tempdb', 'DBAToolbox', 'SSISDB')) AND
             (dc.[DatabaseName] NOT LIKE 'AdventureWorks%') AND
             (dc.[DatabaseName] NOT LIKE 'ReportServer%')
            )
        GROUP BY ms.[ServerName], dc.[DatabaseName], dc.[RecordCreated]

        UNION ALL

        SELECT ms.[ServerName], dc.[DatabaseName], SUM(dc.[SizeMB]) AS [SizeMB], CAST(dc.[RecordCreated] AS date) AS [RecordCreated]
        FROM [Archive].[DatabaseConfigurations] dc
            INNER JOIN [dbo].[MonitoredServers] ms ON COALESCE(ms.[ServerAlias], ms.[ServerName]) = dc.[ServerName]
        -- temporpermanent (?) fix due to incorrect server name in sys.servers 
        WHERE COALESCE(ms.[ServerAlias], ms.[ServerName]) = @ServerName
        --AND dc.[DatabaseName] LIKE @DatabaseName
        AND dc.[FileType] IN ('FILESTREAM', 'ROWS') -- total for data files only
        AND @IncludeArchive = 1 -- depends on input parameter
        AND dc.[RecordCreated] >= DATEADD(M, -@ArchiveMonths, CURRENT_TIMESTAMP)
        -- exclude system databases from initial filter
        AND ((dc.[DatabaseName] IN ('master', 'model', 'msdb', 'tempdb', 'DBAToolbox', 'SSISDB')) AND
             (dc.[DatabaseName] LIKE 'AdventureWorks%') AND
             (dc.[DatabaseName] LIKE 'ReportServer%')
            )
        GROUP BY ms.[ServerName], dc.[DatabaseName], dc.[RecordCreated]
        -- end of archive bit

        UNION ALL

        -- main data set
        SELECT ms.[ServerName], dc.[DatabaseName], SUM(dc.[SizeMB]) AS [SizeMB], CAST(dc.[RecordCreated] AS date) AS [RecordCreated]
        FROM [Monitor].[DatabaseConfigurations] dc
            INNER JOIN [dbo].[MonitoredServers] ms ON COALESCE(ms.[ServerAlias], ms.[ServerName]) = dc.[ServerName]
        -- temporpermanent (?) fix due to incorrect server name in sys.servers 
        WHERE COALESCE(ms.[ServerAlias], ms.[ServerName]) = @ServerName
        AND dc.[DatabaseName] LIKE @DatabaseName
        AND dc.[FileType] IN ('FILESTREAM', 'ROWS') -- total for data files only
        -- exclude system databases from initial filter
        AND ((dc.[DatabaseName] NOT IN ('master', 'model', 'msdb', 'tempdb', 'DBAToolbox', 'SSISDB')) AND
             (dc.[DatabaseName] NOT LIKE 'AdventureWorks%') AND
             (dc.[DatabaseName] NOT LIKE 'ReportServer%')
            )
        GROUP BY ms.[ServerName], dc.[DatabaseName], dc.[RecordCreated]
        
        UNION ALL

        SELECT ms.[ServerName], dc.[DatabaseName], SUM(dc.[SizeMB]) AS [SizeMB], CAST(dc.[RecordCreated] AS date) AS [RecordCreated]
        FROM [Monitor].[DatabaseConfigurations] dc
            INNER JOIN [dbo].[MonitoredServers] ms ON COALESCE(ms.[ServerAlias], ms.[ServerName]) = dc.[ServerName]
        -- temporpermanent (?) fix due to incorrect server name in sys.servers 
        WHERE COALESCE(ms.[ServerAlias], ms.[ServerName]) = @ServerName
        --AND dc.[DatabaseName] LIKE @DatabaseName
        AND dc.[FileType] IN ('FILESTREAM', 'ROWS') -- total for data files only
        -- limit this part to system databases only
        AND ((dc.[DatabaseName] IN ('master', 'model', 'msdb', 'tempdb', 'DBAToolbox', 'SSISDB')) OR
             (dc.[DatabaseName] LIKE 'AdventureWorks%') OR
             (dc.[DatabaseName] LIKE 'ReportServer%'))
        AND (@IncludeSystem = 1) -- include system databases
        GROUP BY ms.[ServerName], dc.[DatabaseName], dc.[RecordCreated]
        -- end of main data set

        ORDER BY [ServerName], [DatabaseName], [RecordCreated];
    END
END
GO


USE [master]
GO


/*
USE [SQLMonitor]
GO
CREATE NONCLUSTERED INDEX [<Name of Missing Index, sysname,>]
    ON [Archive].[DatabaseConfigurations] ([ServerName],[DatabaseName])
GO
*/
