USE [SQLMonitor]
GO

IF OBJECT_ID('[Staging].[ServerConfigurations]') IS NOT NULL
BEGIN
    DROP TABLE [Staging].[ServerConfigurations];
END
GO

CREATE TABLE [Staging].[ServerConfigurations](
	[ServerName] [nvarchar](128) NOT NULL,
    [ConfigID] [int] NOT NULL,
    [ConfigName] [nvarchar](255) NOT NULL,
    [ValueSet] [int] NOT NULL,
    [ValueInUse] [int] NOT NULL,
    [RecordStatus] [char] (1) NOT NULL,        -- record status - used to determine if the record is active or not
    [RecordCreated] [datetimeoffset] (7) NOT NULL   -- audit timestamp storing the date and time the record was created (is additional detail necessary?)
) ON [TABLES]
GO


-- default constraint on RecordStatus = "A"
ALTER TABLE [Staging].[ServerConfigurations] ADD CONSTRAINT
	DF_ServerConfigurations_RecordStatus DEFAULT 'A' FOR RecordStatus
GO

-- default constraint on RecordCreated = SYSDATETIMEOFFSET()
ALTER TABLE [Staging].[ServerConfigurations] ADD CONSTRAINT
	DF_ServerConfigurations_RecordCreated DEFAULT SYSDATETIMEOFFSET() FOR RecordCreated
GO


USE [master]
GO
