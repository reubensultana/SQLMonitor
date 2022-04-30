IF OBJECT_ID('[Archive].[ServerFreeSpace]') IS NOT NULL
DROP TABLE [Archive].[ServerFreeSpace];
GO

CREATE TABLE [Archive].[ServerFreeSpace](
    [ServerFreeSpaceID] [int] NOT NULL,
	[ServerName] [nvarchar](128) NOT NULL,
    [Drive] [char](1) NOT NULL,
    [FreeMB] [int] NOT NULL,
    [RecordStatus] [char] (1) NOT NULL,         -- record status - used to determine if the record is active or not
    [RecordCreated] [datetimeoffset] (7) NOT NULL    -- audit timestamp storing the date and time the record was created (is additional detail necessary?)
)
GO


-- clustered index on ServerInfoID
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'[Archive].[ServerFreeSpace]') AND name = N'PK_ServerFreeSpace_Archive')
ALTER TABLE [Archive].[ServerFreeSpace]
ADD  CONSTRAINT [PK_ServerFreeSpace_Archive] PRIMARY KEY CLUSTERED ([ServerFreeSpaceID] ASC)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON, IGNORE_DUP_KEY = OFF, ONLINE = OFF, 
    ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100)
GO
