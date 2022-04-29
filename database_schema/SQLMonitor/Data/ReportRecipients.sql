/* ----- dbo.ReportRecipients ----- */
/*
-- NOTE: Watch out for single quotes in the PreExecuteScript and ExecuteScript columns
SELECT 
    ',(''' + ReportName + ''',''' + ReportType + ''',''' + CAST(ExecutionOrder AS varchar(10)) + ''',''' + 
    COALESCE(PreExecuteScript, '') + ''',''' + COALESCE(ExecuteScript, '') + ''')'
FROM [SQLMonitor].[dbo].[ReportRecipients]
ORDER BY ReportType, ExecutionOrder, ReportName
*/

-- TRUNCATE TABLE [dbo].[ReportRecipients];
INSERT INTO [dbo].[ReportRecipients] (
    [RecipientName], [RecipientEmailAddress], [SendingOrder], [RecordStatus]
    )
VALUES
     ('DBA Team',      'dba.team@mycompany.com',      1, 'A')
    ,('Jason Bourne',  'jason.bourne@mycompany.com',  1, 'A')
    ,('Mary Poppins',  'mary.poppins@mycompany.com',  1, 'A')
    ,('William Tell',  'william.tell@mycompany.com',  1, 'A')
    ,('Bud Spencer',   'bud.spencer@mycompany.com',   1, 'A')
    ,('Clark Kent',    'clark.kent@mycompany.com',    1, 'A')
    ,('Ugo Fantozzi',  'ugo.fantozzi@mycompany.com',  1, 'A')
    ,('Service Desk',  'servicedesk@mycompany.com',   1, 'H')
GO

/*
-- Test Check Constraint:
INSERT INTO [dbo].[ReportRecipients] ([RecipientName], [RecipientEmailAddress], [SendingOrder], [RecordStatus])
VALUES ('GMAIL Sample', 'firstname.surname@gmail.com', 1, 'A');
*/

-- SELECT * FROM [dbo].[ReportRecipients] ORDER BY [ReportRecipientID]
