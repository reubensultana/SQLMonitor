IF OBJECT_ID('[dbo].[SystemParams]') IS NOT NULL
DROP TABLE [dbo].[SystemParams]
GO

CREATE TABLE [dbo].[SystemParams] (
    [ParamID]           [int] IDENTITY(1,1) NOT NULL,
    [ParamName]         [nvarchar] (128) COLLATE Latin1_General_CI_AS NOT NULL,
    [ParamValue]        [nvarchar] (4000) COLLATE Latin1_General_CI_AS NOT NULL,
    [ParamDescription]  [nvarchar] (4000) COLLATE Latin1_General_CI_AS NOT NULL,
    [RecordStatus]      [char] (1) NOT NULL,       -- record status - used to determine if the record is active or not
    [RecordCreated]     [datetime2] (0) NOT NULL  -- audit timestamp storing the date and time the record was created (is additional detail necessary?)
)
GO

-- clustered index on ParamID
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[SystemParams]') AND name = N'PK_SystemParams')
ALTER TABLE [dbo].[SystemParams]
ADD  CONSTRAINT [PK_SystemParams] PRIMARY KEY CLUSTERED ([ParamID] ASC)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON, IGNORE_DUP_KEY = OFF, ONLINE = OFF, 
    ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100)
GO

-- default constraint on RecordStatus = "A"
ALTER TABLE [dbo].[SystemParams] ADD CONSTRAINT
	DF_SystemParams_RecordStatus DEFAULT 'A' FOR RecordStatus
GO
-- check constraint on RecordStatus - allowed values "A", "D", "H"
ALTER TABLE [dbo].[SystemParams] ADD CONSTRAINT
	CK_SystemParams_RecordStatus CHECK (RecordStatus LIKE '[ADH]')
GO

-- default constraint on RecordCreated = SYSDATETIMEOFFSET()
ALTER TABLE [dbo].[SystemParams] ADD CONSTRAINT
	DF_SystemParams_RecordCreated DEFAULT SYSDATETIMEOFFSET() FOR RecordCreated
GO

-- unique constraint on ParamName
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[SystemParams]') AND name = N'IX_SystemParams_ParamName')
CREATE UNIQUE NONCLUSTERED INDEX [IX_SystemParams_ParamName] 
ON [dbo].[SystemParams] ([ParamName] ASC)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON, DROP_EXISTING = OFF, ONLINE = OFF, 
    ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90)
GO
