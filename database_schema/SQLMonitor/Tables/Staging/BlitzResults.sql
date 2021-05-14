USE [SQLMonitor]
GO

IF OBJECT_ID('[Staging].[BlitzResults]') IS NOT NULL
BEGIN
    DROP TABLE [Staging].[BlitzResults];
END
GO

CREATE TABLE [Staging].[BlitzResults] (
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
    [RecordCreated] [datetimeoffset] (7) NOT NULL    -- audit timestamp storing the date and time the record was created (is additional detail necessary?)
) ON [TABLES]
GO


-- default constraint on RecordStatus = "A"
ALTER TABLE [Staging].[BlitzResults] ADD CONSTRAINT
	DF_BlitzResults_RecordStatus DEFAULT 'A' FOR RecordStatus
GO

-- default constraint on RecordCreated = SYSDATETIMEOFFSET()
ALTER TABLE [Staging].[BlitzResults] ADD CONSTRAINT
	DF_BlitzResults_RecordCreated DEFAULT SYSDATETIMEOFFSET() FOR RecordCreated
GO


USE [master]
GO
