IF OBJECT_ID('[dbo].[Profile]') IS NOT NULL
    DROP TABLE [dbo].[Profile];
GO

CREATE TABLE [dbo].[Profile] (
    [ProfileID]         [int] IDENTITY(1,1) NOT NULL,
    [ProfileName]       [varchar] (50) NOT NULL,   -- equivalent to the destination schema name
    [ScriptName]        [nvarchar] (255) NOT NULL,  -- equivalent to the destination table name
    [ProfileType]       [varchar] (50) NOT NULL,   -- defines execution schedule: Manual, Recurrent, Daily, Weekly, Monthly
    [PreExecuteScript]  [nvarchar] (4000) NOT NULL,   -- optional: script which should be run before every iteration of the main script; used to retrieve single values which can then be used in the main script.
    [ExecuteScript]     [nvarchar] (max) NOT NULL,     -- the actual script which will be executed with each iteration - if empty, the script file will be used instead
    [ExecutionOrder]    [tinyint] NOT NULL DEFAULT(0),
    [RecordStatus]      [char] (1) NOT NULL,       -- record status - used to determine if the record is active or not
    [RecordCreated]     [datetime2] (0) NOT NULL  -- audit timestamp storing the date and time the record was created (is additional detail necessary?)
)
GO


-- clustered index on ProfileID
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[Profile]') AND name = N'PK_Profile')
ALTER TABLE [dbo].[Profile]
ADD  CONSTRAINT [PK_Profile] PRIMARY KEY CLUSTERED ([ProfileID] ASC)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON, IGNORE_DUP_KEY = OFF, ONLINE = OFF, 
    ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100)
GO


-- default constraint on RecordStatus = "A"
ALTER TABLE [dbo].[Profile] ADD CONSTRAINT
	DF_Profile_RecordStatus DEFAULT 'A' FOR RecordStatus
GO
-- check constraint on RecordStatus - allowed values "A", "D", "H"
ALTER TABLE [dbo].[Profile] ADD CONSTRAINT
	CK_Profile_RecordStatus CHECK (RecordStatus LIKE '[ADH]')
GO

-- default constraint on RecordCreated = SYSDATETIMEOFFSET()
ALTER TABLE [dbo].[Profile] ADD CONSTRAINT
	DF_Profile_RecordCreated DEFAULT SYSDATETIMEOFFSET() FOR RecordCreated
GO

-- default constraint on PreExecuteScript = ""
ALTER TABLE [dbo].[Profile] ADD CONSTRAINT
	DF_Profile_PreExecuteScript DEFAULT N'' FOR [PreExecuteScript]
GO

-- default constraint on ExecuteScript = ""
ALTER TABLE [dbo].[Profile] ADD CONSTRAINT
	DF_Profile_ExecuteScript DEFAULT N'' FOR [ExecuteScript]
GO
