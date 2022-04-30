IF EXISTS (SELECT * FROM sys.triggers WHERE parent_class_desc = 'DATABASE' AND name = N'ddlDatabaseTriggerLog')
DISABLE TRIGGER [ddlDatabaseTriggerLog] ON DATABASE
GO

IF OBJECT_ID('[dbo].[DatabaseLog]') IS NOT NULL
DROP TABLE [dbo].[DatabaseLog]
GO

CREATE TABLE [dbo].[DatabaseLog](
	[DatabaseLogID] 	[int] IDENTITY(-2147483648,1) NOT NULL,
	[PostTime] 			[datetimeoffset] (7) NOT NULL,
	[DatabaseUser] 		[nvarchar] (128) COLLATE Latin1_General_CI_AS NOT NULL,
	[Event] 			[nvarchar] (128) COLLATE Latin1_General_CI_AS NOT NULL,
	[Schema] 			[nvarchar] (128) COLLATE Latin1_General_CI_AS NULL,
	[Object] 			[nvarchar] (128) COLLATE Latin1_General_CI_AS NULL,
	[TSQL] 				[nvarchar](max) COLLATE Latin1_General_CI_AS NOT NULL,
	[XmlEvent] 			[xml] NOT NULL
)
GO

-- clustered index on DatabaseLogID
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[DatabaseLog]') AND name = N'PK_DatabaseLog')
ALTER TABLE [dbo].[DatabaseLog]
ADD CONSTRAINT [PK_DatabaseLog] PRIMARY KEY CLUSTERED ([DatabaseLogID] ASC)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON, IGNORE_DUP_KEY = OFF, ONLINE = OFF, 
    ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100)
GO

-- default constraint on PostTime = SYSDATETIMEOFFSET()
ALTER TABLE [dbo].[DatabaseLog] ADD CONSTRAINT 
    [DF_DatabaseLog_PostTime]  DEFAULT (SYSDATETIMEOFFSET()) FOR [PostTime]
GO
