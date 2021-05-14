USE [SQLMonitor]
GO

IF OBJECT_ID('[Staging].[ServerTriggers]') IS NOT NULL
BEGIN
    DROP TABLE [Staging].[ServerTriggers];
END
GO

CREATE TABLE [Staging].[ServerTriggers](
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


-- default constraint on RecordStatus = "A"
ALTER TABLE [Staging].[ServerTriggers] ADD CONSTRAINT
	DF_ServerTriggers_RecordStatus DEFAULT 'A' FOR RecordStatus
GO

-- default constraint on RecordCreated = SYSDATETIMEOFFSET()
ALTER TABLE [Staging].[ServerTriggers] ADD CONSTRAINT
	DF_ServerTriggers_RecordCreated DEFAULT SYSDATETIMEOFFSET() FOR RecordCreated
GO


USE [master]
GO
