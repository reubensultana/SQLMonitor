USE [SQLMonitorArchive]
GO

IF OBJECT_ID('[Archive].[ServerTriggers]') IS NOT NULL
BEGIN
    DROP TABLE [Archive].[ServerTriggers];
END
GO

CREATE TABLE [Archive].[ServerTriggers](
    [ServerTriggerID] [int] NOT NULL,
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
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'[Archive].[ServerTriggers]') AND name = N'PK_ServerTriggers_Archive')
ALTER TABLE [Archive].[ServerTriggers]
ADD  CONSTRAINT [PK_ServerTriggers_Archive] PRIMARY KEY CLUSTERED ([ServerTriggerID] ASC)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON, IGNORE_DUP_KEY = OFF, ONLINE = OFF, 
    ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [TABLES]
GO


USE [master]
GO
