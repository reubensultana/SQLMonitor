USE [SQLMonitor]
GO

IF OBJECT_ID(N'[dbo].[uspGetProfile]') IS NOT NULL
DROP PROCEDURE [dbo].[uspGetProfile]
GO

CREATE PROCEDURE [dbo].[uspGetProfile] 
    @ProfileName varchar(50),
    @ProfileType varchar(50)
AS
BEGIN
    SET NOCOUNT ON;

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
    
    -- an integer indicating the number of minutes that should elapse between iterations
    DECLARE @IntervalMinutes int = 
        CASE @ProfileType
            WHEN 'Annual'   THEN DATEDIFF(N, DATEADD(YY, -1, CURRENT_TIMESTAMP), CURRENT_TIMESTAMP)
            WHEN 'Monthly'  THEN DATEDIFF(N, DATEADD(MM, -1, CURRENT_TIMESTAMP), CURRENT_TIMESTAMP)
            WHEN 'Weekly'   THEN DATEDIFF(N, DATEADD(WW, -1, CURRENT_TIMESTAMP), CURRENT_TIMESTAMP)
            WHEN 'Daily'    THEN DATEDIFF(N, DATEADD(DD, -1, CURRENT_TIMESTAMP), CURRENT_TIMESTAMP)
            WHEN 'Hourly'   THEN DATEDIFF(N, DATEADD(HH, -1, CURRENT_TIMESTAMP), CURRENT_TIMESTAMP)
            WHEN 'Minute'   THEN DATEDIFF(N, DATEADD(N , -1, CURRENT_TIMESTAMP), CURRENT_TIMESTAMP)
            WHEN 'Manual'   THEN 0
            ELSE 0
        END;
    
    SELECT 
        p.[ScriptName], p.[PreExecuteScript], p.[ExecuteScript], 
        @IntervalMinutes AS [IntervalMinutes]
    FROM [dbo].[Profile] p
    WHERE p.[ProfileName] = @ProfileName AND p.[ProfileType] = @ProfileType
    ORDER BY p.[ExecutionOrder], p.[ScriptName];
    
END
GO


USE [master]
GO
