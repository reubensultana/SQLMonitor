IF OBJECT_ID(N'[Reporting].[uspBlitzResults4Email]') IS NOT NULL
DROP PROCEDURE [Reporting].[uspBlitzResults4Email] 
GO

CREATE PROCEDURE [Reporting].[uspBlitzResults4Email] 
    @ServerOrder smallint = 1,  -- Production servers by default
    @ServerName nvarchar(128) = NULL,
    @Priority tinyint = NULL,
    @CheckID int = NULL
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON;
    /*-- NOTE: If anything is changed here make sure the same is applied to uspBlitzResults --*/
    SELECT 
        br.[ServerName]
        ,br.[DatabaseName]
        ,br.[Details]
        ,br.[URL]
    
    FROM [Monitor].[BlitzResults] br
        INNER JOIN [dbo].[MonitoredServers] ms ON br.[ServerName] = COALESCE(ms.[ServerAlias], ms.[ServerName])
    -- CheckID exclusions based on https://github.com/BrentOzarULTD/SQL-Server-First-Responder-Kit/blob/master/Documentation/sp_Blitz%20Checks%20by%20Priority.md
    WHERE br.[CheckID] NOT IN (
        -1      -- Thanks!; From Your Community Volunteers
        ,49     -- Informational; Linked Server Configured
        ,53     -- Informational; Cluster Node
        ,74     -- Informational; TraceFlag On
        ,76     -- Informational; Collation is...
        ,83     -- Server Info; Services
        ,84     -- Server Info; Hardware
        ,85     -- Server Info; SQL Server Service
        ,92     -- Server Info; Drive Space
        ,103    -- Server Info; Virtual Server
        ,106    -- Server Info; Default Trace Contents
        ,114    -- Server Info; Hardware - NUMA Config
        ,130    -- Server Info; Server Name
        ,153    -- Wait Stats; No Significant Waits Detected
        ,155    -- Outdated sp_Blitz; sp_Blitz is Over 6 Months Old
        ,156    -- Rundate; (Current Date)
        ,193    -- Server Info; Instant File Initialization Enabled
        ,204    -- Informational; @CheckUserDatabaseObjects Disabled
    )
    -- production servers are usually set to "1"
    AND ms.[ServerOrder] = COALESCE(@ServerOrder, ms.[ServerOrder])
    -- temporpermanent (?) fix due to incorrect server name in sys.servers
    AND COALESCE(ms.[ServerAlias], ms.[ServerName]) LIKE COALESCE(NULLIF(@ServerName, ''), '%')

    AND br.[Priority] = COALESCE(@Priority, br.[Priority])
    AND br.[CheckID] = COALESCE(@CheckID, br.[CheckID])

    ORDER BY br.[Priority], br.[CheckID], br.[FindingsGroup], br.[ServerName], br.[DatabaseName]

END
GO

-- EXEC [Reporting].[uspBlitzResults4Email]
-- EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=NULL
-- EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 1, @CheckID = 1; -- Backup; Backups Not Performed Recently
-- EXEC [Reporting].[uspBlitzResults4Email] @ServerOrder=1, @Priority = 1, @CheckID = 2; -- Backup; Full Recovery Model w/o Log Backups
