IF OBJECT_ID(N'[dbo].[uspGetProfile]') IS NOT NULL
DROP PROCEDURE [dbo].[uspGetProfile]
GO

CREATE PROCEDURE [dbo].[uspGetProfile] 
    @ProfileName varchar(50),
    @ProfileType varchar(50)
AS
BEGIN
    SET NOCOUNT ON;
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    
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
    
    SELECT 
        p.[ScriptName], p.[PreExecuteScript], p.[ExecuteScript], 
        p.[IntervalMinutes]
    FROM [dbo].[vwProfile] p
    WHERE p.[ProfileName] = @ProfileName AND p.[ProfileType] = @ProfileType
    ORDER BY [IntervalMinutes], p.[ProfileName], p.[ExecutionOrder], p.[ScriptName];
    
END
GO
