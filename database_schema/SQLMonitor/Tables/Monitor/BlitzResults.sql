USE [SQLMonitor]
GO

IF OBJECT_ID('[Monitor].[BlitzResults]') IS NOT NULL
BEGIN
    DROP TABLE [Monitor].[BlitzResults];
END
GO

CREATE TABLE [Monitor].[BlitzResults] (
	[BlitzResultID] INT IDENTITY(-2147483648, 1) NOT NULL ,
    [ServerName] NVARCHAR(128) ,
	[Priority] TINYINT ,
	[FindingsGroup] VARCHAR(50) ,
	[Finding] VARCHAR(200) ,
	[DatabaseName] NVARCHAR(128) ,
	[URL] VARCHAR(200) ,
	[Details] NVARCHAR(4000) ,
	[QueryPlan] [XML] NULL ,
	[QueryPlanFiltered] [NVARCHAR](MAX) NULL ,
	[CheckID] INT ,
    [RecordStatus] [char] (1) NOT NULL,         -- record status - used to determine if the record is active or not
    [RecordCreated] [datetime2] (0) NOT NULL    -- audit timestamp storing the date and time the record was created (is additional detail necessary?)
) ON [TABLES]
GO


-- clustered index on DatabaseTableID
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'[Monitor].[BlitzResults]') AND name = N'PK_BlitzResults')
ALTER TABLE [Monitor].[BlitzResults]
ADD  CONSTRAINT [PK_BlitzResults] PRIMARY KEY CLUSTERED ([BlitzResultID] ASC)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON, IGNORE_DUP_KEY = OFF, ONLINE = OFF, 
    ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [TABLES]
GO

-- indexes created for performance
CREATE NONCLUSTERED INDEX [IX_BlitzResults_ServerName]
ON [Monitor].[BlitzResults] ([ServerName])
WITH (
    PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON, IGNORE_DUP_KEY = OFF, 
    DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90
)
GO

-- default constraint on RecordStatus = "A"
ALTER TABLE [Monitor].[BlitzResults] ADD CONSTRAINT
	DF_BlitzResults_RecordStatus DEFAULT 'A' FOR RecordStatus
GO
-- check constraint on RecordStatus - allowed values "A", "D", "H"
ALTER TABLE [Monitor].[BlitzResults] ADD CONSTRAINT
	CK_BlitzResults_RecordStatus CHECK (RecordStatus LIKE '[ADH]')
GO

-- default constraint on RecordCreated = CURRENT_TIMESTAMP
ALTER TABLE [Monitor].[BlitzResults] ADD CONSTRAINT
	DF_BlitzResults_RecordCreated DEFAULT CURRENT_TIMESTAMP FOR RecordCreated
GO


USE [master]
GO
