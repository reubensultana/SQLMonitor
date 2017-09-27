USE [SQLMonitor]
GO

IF OBJECT_ID(N'[Reporting].[uspListDatabaseGrowthTrend]') IS NOT NULL
DROP PROCEDURE [Reporting].[uspListDatabaseGrowthTrend]
GO

CREATE PROCEDURE [Reporting].[uspListDatabaseGrowthTrend] 
    @ServerName nvarchar(128) = '',
    @DatabaseName nvarchar(128) = '',
    @IncludeArchive bit = 0
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON;

    IF ((COALESCE(@ServerName, NULLIF(LTRIM(RTRIM(@ServerName)), '')) IS NOT NULL) AND
        (COALESCE(@DatabaseName, NULLIF(LTRIM(RTRIM(@DatabaseName)), '')) IS NOT NULL)
        -- and server name value is valid
        AND EXISTS(
            SELECT 1 FROM [dbo].[MonitoredServers] WHERE [RecordStatus] = 'A' --AND [ServerName]=@ServerName
            -- temporpermanent (?) fix due to incorrect server name in sys.servers on CFSDGLPEGSQL01-PROD
            AND [ServerName]=(CASE @ServerName WHEN 'CFSDGLPEGSQL01-' THEN 'CFSDGLPEGSQL01-PROD' ELSE @ServerName END))
        -- and database name value is valid
        AND EXISTS(
            SELECT 1 FROM [Monitor].[ServerDatabases] WHERE [RecordStatus] = 'A' --AND [ServerName]=@ServerName
            -- temporpermanent (?) fix due to incorrect server name in sys.servers on CFSDGLPEGSQL01-PROD
            AND [ServerName]=(CASE @ServerName WHEN 'CFSDGLPEGSQL01-PROD' THEN 'CFSDGLPEGSQL01-' ELSE @ServerName END)
            AND [DatabaseName] LIKE @DatabaseName)
        )
    BEGIN
        SELECT [ServerName], [DatabaseName], SUM([SizeMB]) AS [SizeMB], CAST([RecordCreated] AS date) AS [RecordCreated]
        FROM [Archive].[DatabaseConfigurations]
        -- WHERE [ServerName] = @ServerName
        -- temporpermanent (?) fix due to incorrect server name in sys.servers on CFSDGLPEGSQL01-PROD
        WHERE [ServerName]=(CASE @ServerName WHEN 'CFSDGLPEGSQL01-PROD' THEN 'CFSDGLPEGSQL01-' ELSE @ServerName END)
        AND [DatabaseName] LIKE @DatabaseName
        AND [FileType] IN ('FILESTREAM', 'ROWS') -- total for data files only
        AND @IncludeArchive = 1 -- depends on input parameter
        GROUP BY [ServerName], [DatabaseName], [RecordCreated]

        UNION ALL

        SELECT [ServerName], [DatabaseName], SUM([SizeMB]) AS [SizeMB], CAST([RecordCreated] AS date) AS [RecordCreated]
        FROM [Monitor].[DatabaseConfigurations]
        -- WHERE [ServerName] = @ServerName
        -- temporpermanent (?) fix due to incorrect server name in sys.servers on CFSDGLPEGSQL01-PROD
        WHERE [ServerName]=(CASE @ServerName WHEN 'CFSDGLPEGSQL01-PROD' THEN 'CFSDGLPEGSQL01-' ELSE @ServerName END)
        AND [DatabaseName] LIKE @DatabaseName
        AND [FileType] IN ('FILESTREAM', 'ROWS') -- total for data files only
        GROUP BY [ServerName], [DatabaseName], [RecordCreated];
    END
END
GO


-- EXEC [Reporting].[uspListDatabaseGrowthTrend] @ServerName = 'CFSDGLSPSAPPV', @DatabaseName = '%';
-- EXEC [Reporting].[uspListDatabaseGrowthTrend] @ServerName = 'CFSDGLSPSAPPV', @DatabaseName = 'Opswise';
-- EXEC [Reporting].[uspListDatabaseGrowthTrend] @ServerName = 'CFSDGLSPSAPPV', @DatabaseName = 'Opswise', @IncludeArchive = 1;

-- EXEC [Reporting].[uspListDatabaseGrowthTrend] @ServerName = 'CFSDGLPEGSQL01-PROD', @DatabaseName = '%';
-- EXEC [Reporting].[uspListDatabaseGrowthTrend] @ServerName = 'CFSDGLPEGSQL01-PROD', @DatabaseName = 'PEGA1';
-- EXEC [Reporting].[uspListDatabaseGrowthTrend] @ServerName = 'CFSDGLPEGSQL01-PROD', @DatabaseName = 'PEGA1', @IncludeArchive = 1;

USE [master]
GO


/*
USE [SQLMonitor]
GO
CREATE NONCLUSTERED INDEX [<Name of Missing Index, sysname,>]
    ON [Archive].[DatabaseConfigurations] ([ServerName],[DatabaseName])
GO
*/
