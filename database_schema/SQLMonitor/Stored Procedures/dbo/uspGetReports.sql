USE [SQLMonitor]
GO

IF OBJECT_ID(N'[dbo].[uspGetReports]') IS NOT NULL
DROP PROCEDURE [dbo].[uspGetReports]
GO

CREATE PROCEDURE [dbo].[uspGetReports] 
    @ReportType varchar(50)
AS
BEGIN
    SET NOCOUNT ON;
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    
    -- the only allowed types
    IF (@ReportType NOT IN (
        'Monthly', 'Weekly', 'Daily', 'Manual', 'Custom Monthly', 'Custom Weekly', 'Custom Daily', 'Custom Test'))
    BEGIN
        RAISERROR('Invalid Report Type.', 16, 1)
        RETURN -1
    END

    SELECT 
        r.ReportID, r.ReportName, r.ReportType, r.ExecuteScript
        ,rr.RecipientName, rr.RecipientEmailAddress
        ,r.CreateChart
    FROM [dbo].[Reports] r
        -- get only assigned reports, or all if wildcard is used
        INNER JOIN [dbo].[ReportRecipients] rr ON ((r.ReportID = rr.ReportID) OR (rr.ReportID IS NULL AND r.ReportType NOT LIKE 'Custom%'))
    -- active reports and recipients
    WHERE r.RecordStatus = 'A' AND rr.RecordStatus = 'A'
    -- limit to a specific type
    AND r.ReportType = @ReportType
    ORDER BY rr.SendingOrder, rr.RecipientName, r.ExecutionOrder;

END
GO


USE [master]
GO
