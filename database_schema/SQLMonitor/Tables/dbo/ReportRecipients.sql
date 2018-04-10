USE [SQLMonitor]
GO

IF OBJECT_ID('[dbo].[ReportRecipients]') IS NOT NULL
    DROP TABLE [dbo].[ReportRecipients];
GO

CREATE TABLE [dbo].[ReportRecipients] (
    [ReportRecipientID] [int] IDENTITY(1,1) NOT NULL,
    [ReportID] [int] NULL,
    [RecipientName] [varchar](50) NOT NULL,
    [RecipientEmailAddress] [varchar](65) NOT NULL,
    [SendingOrder] [tinyint] NOT NULL DEFAULT(0),
    [RecordStatus] [char] (1) NOT NULL,       -- record status - used to determine if the record is active or not
    [RecordCreated] [datetime2] (0) NOT NULL  -- audit timestamp storing the date and time the record was created (is additional detail necessary?)
) ON [TABLES]
GO


-- clustered index on ProfileID
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[ReportRecipients]') AND name = N'PK_ReportRecipient')
ALTER TABLE [dbo].[ReportRecipients]
ADD  CONSTRAINT [PK_ReportRecipient] PRIMARY KEY CLUSTERED ([ReportRecipientID] ASC)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON, IGNORE_DUP_KEY = OFF, ONLINE = OFF, 
    ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [TABLES]
GO

-- nonclustered index on ReportID and RecipientEmailAddress to enforce uniqueness
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[ReportRecipients]') 
	       AND name = N'IDX_ReportRecipients_ID_EmailAddress')
CREATE UNIQUE NONCLUSTERED INDEX [IDX_ReportRecipients_ID_EmailAddress]
    ON [dbo].[ReportRecipients] ( [ReportID] ASC, [RecipientEmailAddress] ASC )
WITH (
    PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, 
    ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [TABLES]
GO


-- check constraint on RecipientEmailAddress - allowed values are properly formed company email addresses
ALTER TABLE [dbo].[ReportRecipients] ADD CONSTRAINT
	CK_ReportRecipient_RecipientEmailAddress CHECK (RecipientEmailAddress NOT LIKE '%[^a-z,0-9,@,.]%' 
							AND RecipientEmailAddress LIKE '%_@mycompany.com')
GO

-- default constraint on RecordStatus = "A"
ALTER TABLE [dbo].[ReportRecipients] ADD CONSTRAINT
	DF_ReportRecipient_RecordStatus DEFAULT 'A' FOR RecordStatus
GO
-- check constraint on RecordStatus - allowed values "A", "D", "H"
ALTER TABLE [dbo].[ReportRecipients] ADD CONSTRAINT
	CK_ReportRecipient_RecordStatus CHECK (RecordStatus LIKE '[ADH]')
GO

-- default constraint on RecordCreated = CURRENT_TIMESTAMP
ALTER TABLE [dbo].[ReportRecipients] ADD CONSTRAINT
	DF_ReportRecipient_RecordCreated DEFAULT CURRENT_TIMESTAMP FOR RecordCreated
GO


USE [master]
GO
