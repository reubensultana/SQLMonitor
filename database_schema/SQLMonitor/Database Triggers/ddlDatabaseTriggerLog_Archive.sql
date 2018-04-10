USE [SQLMonitorArchive]
GO

IF EXISTS (SELECT * FROM sys.triggers WHERE parent_class_desc = 'DATABASE' AND name = N'ddlDatabaseTriggerLog')
DROP TRIGGER [ddlDatabaseTriggerLog] ON DATABASE
GO

CREATE TRIGGER [ddlDatabaseTriggerLog] ON DATABASE 
FOR DDL_DATABASE_LEVEL_EVENTS AS 
BEGIN
    SET NOCOUNT ON;

    DECLARE @data XML;
    DECLARE @schema nvarchar(128);
    DECLARE @object nvarchar(128);
    DECLARE @eventType nvarchar(128);

    SET @data = EVENTDATA();
    SET @eventType = @data.value('(/EVENT_INSTANCE/EventType)[1]', 'sysname');
    SET @schema = @data.value('(/EVENT_INSTANCE/SchemaName)[1]', 'sysname');
    SET @object = @data.value('(/EVENT_INSTANCE/ObjectName)[1]', 'sysname') 

    --IF @object IS NOT NULL
    --    PRINT '  ' + @eventType + ' - ' + @schema + '.' + @object;
    --ELSE
    --    PRINT '  ' + @eventType + ' - ' + @schema;

    --IF @eventType IS NULL
    --    PRINT CONVERT(nvarchar(max), @data);

    INSERT [dbo].[DatabaseLog] (
        [PostTime], 
        [DatabaseUser], 
        [Event], 
        [Schema], 
        [Object], 
        [TSQL], 
        [XmlEvent]
        ) 
    VALUES (
        CURRENT_TIMESTAMP, 
        CONVERT(nvarchar(128), CURRENT_USER), 
        @eventType, 
        CONVERT(nvarchar(128), @schema), 
        CONVERT(nvarchar(128), @object), 
        @data.value('(/EVENT_INSTANCE/TSQLCommand)[1]', 'nvarchar(max)'), 
        @data
        );
END;
GO

ENABLE TRIGGER [ddlDatabaseTriggerLog] ON DATABASE
GO


USE [master]
GO
