USE [SQLMonitor]
GO

IF OBJECT_ID(N'[Monitor].[uspMoveStagingData]') IS NOT NULL
DROP PROCEDURE [Monitor].[uspMoveStagingData] 
GO

CREATE PROCEDURE [Monitor].[uspMoveStagingData] 
    @ProfileName varchar(50),
    @ProfileType varchar(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- the only allowed types
    IF (@ProfileType NOT IN (
        'Annual', 'Monthly', 'Weekly', 'Daily', 'Hourly', 'Minute', 'Manual'))
    BEGIN
        RAISERROR('Invalid Profile Type.', 16, 1)
        RETURN -1
    END

    IF NOT EXISTS(SELECT 1 FROM [dbo].[Profile] WHERE [ProfileName] = @ProfileName)
    BEGIN
        RAISERROR('Invalid Profile Name.', 16, 1)
        RETURN -1
    END

    -- get list of tables for the selected Profile and ProfileType
    

    INSERT INTO [Monitor].[BlitzResults]
    SELECT * FROM [Staging].[BlitzResults];



    -- clear tables for the selected Profile and ProfileType
    TRUNCATE TABLE [Staging].[BlitzResults];
    TRUNCATE TABLE [Staging].[DatabaseBackupHistory];
    TRUNCATE TABLE [Staging].[DatabaseConfigurations];
    TRUNCATE TABLE [Staging].[DatabaseTableColumns];
    TRUNCATE TABLE [Staging].[DatabaseTables];
    TRUNCATE TABLE [Staging].[DatabaseUsers];
    TRUNCATE TABLE [Staging].[IndexUsageStats];
    TRUNCATE TABLE [Staging].[MissingIndexStats];
    TRUNCATE TABLE [Staging].[ServerAgentConfig];
    TRUNCATE TABLE [Staging].[ServerAgentJobs];
    TRUNCATE TABLE [Staging].[ServerAgentJobsHistory];
    TRUNCATE TABLE [Staging].[ServerConfigurations];
    TRUNCATE TABLE [Staging].[ServerDatabases];
    TRUNCATE TABLE [Staging].[ServerEndpoints];
    TRUNCATE TABLE [Staging].[ServerErrorLog];
    TRUNCATE TABLE [Staging].[ServerFreeSpace];
    TRUNCATE TABLE [Staging].[ServerInfo];
    TRUNCATE TABLE [Staging].[ServerLogins];
    TRUNCATE TABLE [Staging].[ServerServers];
    TRUNCATE TABLE [Staging].[ServerTriggers];

END
GO


USE [master]
GO
