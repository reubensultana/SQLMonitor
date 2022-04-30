IF OBJECT_ID('[dbo].[ErrorLog]') IS NOT NULL
DROP TABLE [dbo].[ErrorLog]
GO

CREATE TABLE [dbo].[ErrorLog] (
	[ErrorLogID] 		[int] IDENTITY(-2147483648,1) NOT NULL,
	[ErrorTime] 		[datetimeoffset] (7) NOT NULL,
	[UserName] 			[nvarchar] (128) COLLATE Latin1_General_CI_AS NOT NULL,
	[ErrorNumber] 		[int] NOT NULL,
	[ErrorSeverity] 	[int] NULL,
	[ErrorState] 		[int] NULL,
	[ErrorProcedure] 	[nvarchar](128) COLLATE Latin1_General_CI_AS NULL,
	[ErrorLine] 		[int] NULL,
	[ErrorMessage] 		[nvarchar](4000) COLLATE Latin1_General_CI_AS NOT NULL
)
GO

-- clustered index on ErrorLogID
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[ErrorLog]') AND name = N'PK_ErrorLog')
ALTER TABLE [dbo].[ErrorLog]
ADD  CONSTRAINT [PK_ErrorLog] PRIMARY KEY CLUSTERED ([ErrorLogID] ASC)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON, IGNORE_DUP_KEY = OFF, ONLINE = OFF, 
    ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100)
GO

-- default constraint on ErrorTime = SYSDATETIMEOFFSET()
ALTER TABLE [dbo].[ErrorLog] ADD CONSTRAINT 
    [DF_ErrorLog_ErrorTime]  DEFAULT (SYSDATETIMEOFFSET()) FOR [ErrorTime]
GO
