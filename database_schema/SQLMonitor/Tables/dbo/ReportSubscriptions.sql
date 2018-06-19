USE [SQLMonitor]
GO

IF OBJECT_ID('[dbo].[ReportSubscriptions]') IS NOT NULL
    DROP TABLE [dbo].[ReportSubscriptions];
GO

CREATE TABLE [dbo].[ReportSubscriptions] (
    [ReportSubscriptionID] [int] IDENTITY(1,1) NOT NULL,
    [ReportRecipient] [int] NOT NULL,
    [ReportID] [int] NULL,                    -- can be NULL to represent "all reports" option
    [RecordStatus] [char] (1) NOT NULL,       -- record status - used to determine if the record is active or not
    [RecordCreated] [datetime2] (0) NOT NULL  -- audit timestamp storing the date and time the record was created (is additional detail necessary?)
) ON [TABLES]
GO


-- clustered index on ProfileID
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[ReportSubscriptions]') AND name = N'PK_ReportSubscription')
ALTER TABLE [dbo].[ReportSubscriptions]
ADD  CONSTRAINT [PK_ReportSubscription] PRIMARY KEY CLUSTERED ([ReportSubscriptionID] ASC)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON, IGNORE_DUP_KEY = OFF, ONLINE = OFF, 
    ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [TABLES]
GO

-- default constraint on RecordStatus = "A"
ALTER TABLE [dbo].[ReportSubscriptions] ADD CONSTRAINT
	DF_ReportSubscription_RecordStatus DEFAULT 'A' FOR RecordStatus
GO
-- check constraint on RecordStatus - allowed values "A", "D", "H"
ALTER TABLE [dbo].[ReportSubscriptions] ADD CONSTRAINT
	CK_ReportSubscription_RecordStatus CHECK (RecordStatus LIKE '[ADH]')
GO

-- default constraint on RecordCreated = CURRENT_TIMESTAMP
ALTER TABLE [dbo].[ReportSubscriptions] ADD CONSTRAINT
	DF_ReportSubscription_RecordCreated DEFAULT CURRENT_TIMESTAMP FOR RecordCreated
GO


USE [master]
GO
