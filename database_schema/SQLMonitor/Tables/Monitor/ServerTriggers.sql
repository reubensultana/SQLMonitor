USE [SQLMonitor]
GO

IF OBJECT_ID('[Monitor].[ServerTriggers]') IS NOT NULL
BEGIN
    DROP TABLE [Monitor].[ServerTriggers];
END
GO

CREATE TABLE [Monitor].[ServerTriggers](
    [ServerTriggerID] [int] IDENTITY(-2147483648,1) NOT NULL,
	[ServerName] [nvarchar](128) NOT NULL,
    [ObjectName] [nvarchar](128) NOT NULL,
    [ObjectType] [nvarchar](60) NOT NULL,
    [CreateDate] [datetime] NOT NULL,
    [ModifyDate] [datetime] NOT NULL,
    [IsDisabled] [bit] NOT NULL,
    [RecordStatus] [char] (1) NOT NULL,         -- record status - used to determine if the record is active or not
    [RecordCreated] [datetimeoffset] (7) NOT NULL    -- audit timestamp storing the date and time the record was created (is additional detail necessary?)
) ON [TABLES]
GO


-- clustered index on ServerInfoID
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'[Monitor].[ServerTriggers]') AND name = N'PK_ServerTriggers')
ALTER TABLE [Monitor].[ServerTriggers]
ADD  CONSTRAINT [PK_ServerTriggers] PRIMARY KEY CLUSTERED ([ServerTriggerID] ASC)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON, IGNORE_DUP_KEY = OFF, ONLINE = OFF, 
    ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [TABLES]
GO


-- default constraint on RecordStatus = "A"
ALTER TABLE [Monitor].[ServerTriggers] ADD CONSTRAINT
	DF_ServerTriggers_RecordStatus DEFAULT 'A' FOR RecordStatus
GO
-- check constraint on RecordStatus - allowed values "A", "D", "H"
ALTER TABLE [Monitor].[ServerTriggers] ADD CONSTRAINT
	CK_ServerTriggers_RecordStatus CHECK (RecordStatus LIKE '[ADH]')
GO

-- default constraint on RecordCreated = SYSDATETIMEOFFSET()
ALTER TABLE [Monitor].[ServerTriggers] ADD CONSTRAINT
	DF_ServerTriggers_RecordCreated DEFAULT SYSDATETIMEOFFSET() FOR RecordCreated
GO


USE [master]
GO
