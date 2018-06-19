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
    FROM [dbo].[ReportSubscriptions] rs
        INNER JOIN [dbo].[ReportRecipients] rr ON rs.ReportRecipient = rr.ReportRecipientID
        -- get only assigned reports, or all if wildcard is used
        INNER JOIN [dbo].[Reports] r ON ((r.ReportID = rs.ReportID) OR ((rs.ReportID IS NULL) AND (r.ReportType NOT LIKE 'Custom%')))
        
    -- active reports and recipients
    WHERE rs.RecordStatus = 'A' AND rr.RecordStatus = 'A' AND r.RecordStatus = 'A'
    -- limit to a specific type
    AND r.ReportType = @ReportType
    ORDER BY rr.SendingOrder, rr.RecipientName, r.ExecutionOrder;

END
GO


USE [master]
GO
