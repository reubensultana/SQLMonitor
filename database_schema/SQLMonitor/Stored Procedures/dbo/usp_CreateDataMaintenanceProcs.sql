USE [SQLMonitor]
GO

-- EXEC [SQLMonitor].[dbo].[usp_CreateDataMaintenanceProcs] 'REPORT'
-- EXEC [SQLMonitor].[dbo].[usp_CreateDataMaintenanceProcs] 'CREATE'

IF OBJECT_ID(N'[dbo].[usp_CreateDataMaintenanceProcs]') IS NOT NULL
DROP PROCEDURE [dbo].[usp_CreateDataMaintenanceProcs]
GO

CREATE PROCEDURE [dbo].[usp_CreateDataMaintenanceProcs]
    @Operation varchar(10) = 'REPORT',
    @SourceSchemaName varchar(128) = 'Monitor',
    @DestinationSchemaName varchar(128) = 'Archive'
AS
BEGIN
    SET NOCOUNT ON;
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    -- check input parameter values
    IF (UPPER(@Operation) NOT IN ('CREATE', 'REPORT'))
    BEGIN
        RAISERROR('Invalid operation', 16, 1);
        RETURN -1;  
    END;

    IF (@SourceSchemaName NOT IN (SELECT [name] FROM sys.schemas WHERE [schema_id] BETWEEN 5 AND 16383))
    BEGIN
        RAISERROR('Invalid schema', 16, 1);
        RETURN -1;
    END;

    IF (@DestinationSchemaName NOT IN (SELECT [name] FROM sys.schemas WHERE [schema_id] BETWEEN 5 AND 16383))
    BEGIN
        RAISERROR('Invalid schema', 16, 1);
        RETURN -1;
    END;

    CREATE TABLE #ObjectDefinitions (
        ObjectName nvarchar(128), 
        ObjectDrop nvarchar(max),
        ObjectCreate nvarchar(max)
    );

    WITH cte_MainTables AS (
        SELECT 
            CAST(OBJECT_SCHEMA_NAME(i.object_id, DB_ID()) AS varchar(128)) AS [TABLE_SCHEMA], 
            CAST(OBJECT_NAME(i.object_id) AS varchar(128)) AS [TABLE_NAME], 
            CAST(c.name AS varchar(128)) AS [COLUMN_NAME]
        FROM sys.index_columns ic
            INNER JOIN sys.indexes i ON (ic.object_id = i.object_id AND ic.index_id = i.index_id)
            INNER JOIN sys.columns c ON (ic.object_id = c.object_id AND ic.column_id = c.column_id)
        WHERE i.object_id > 99 AND i.type = 1
        AND OBJECT_SCHEMA_NAME(i.object_id, DB_ID()) = @SourceSchemaName
    )
    INSERT INTO #ObjectDefinitions (ObjectName, ObjectDrop, ObjectCreate)
    SELECT [TABLE_NAME], '
IF OBJECT_ID(N''[' + @DestinationSchemaName + '].[usp_Mantain_' + [TABLE_NAME] + ']'') IS NOT NULL
DROP PROCEDURE [' + @DestinationSchemaName + '].[usp_Mantain_' + [TABLE_NAME] + '];
', 
'
CREATE PROCEDURE [' + @DestinationSchemaName + '].[usp_Mantain_' + [TABLE_NAME] + ']
AS
BEGIN
    -- ' + [TABLE_NAME] + '
    SET NOCOUNT ON;
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

    DECLARE @CurrentDate date = CURRENT_TIMESTAMP;
    DECLARE @DaysParamValue int;
    DECLARE @RecordsMoved int;
    DECLARE @RecordsDeleted int;
    DECLARE @IDList TABLE (TableID int);
    DECLARE @TableName nvarchar(128) = N''' + [TABLE_NAME] + ''';
    
    -- archival parameters
    DECLARE @ArchiveDate datetime = NULL;
    DECLARE @ArchiveBatchCount int = (
        SELECT CAST([ParamValue] AS int) FROM [dbo].[SystemParams] 
        WHERE [RecordStatus] = ''A'' AND [ParamName] = ''Archive_BatchCount'');
    SET @DaysParamValue = (
        SELECT CAST([ParamValue] AS int) FROM [dbo].[SystemParams] 
        WHERE [RecordStatus] = ''A'' AND [ParamName] = ''Archive_Days_'' + @TableName);
    -- failsafe
    SET @DaysParamValue = COALESCE(@DaysParamValue, 100);
    SET @ArchiveBatchCount = COALESCE(@ArchiveBatchCount, 1000);
    -- define archive date
    SET @ArchiveDate = DATEADD(d, 0-@DaysParamValue, @CurrentDate);

    -- deletion parameters
    -- reinitialize the @DaysParamValue
    SET @DaysParamValue = NULL;
    DECLARE @DeletionDate datetime = NULL;
    DECLARE @DeleteBatchCount int = (
        SELECT CAST([ParamValue] AS int) FROM [dbo].[SystemParams] 
        WHERE [RecordStatus] = ''A'' AND [ParamName] = ''Delete_BatchCount'');
    SET @DaysParamValue = (
        SELECT CAST([ParamValue] AS int) FROM [dbo].[SystemParams] 
        WHERE [RecordStatus] = ''A'' AND [ParamName] = ''Delete_Days_'' + @TableName);
    -- failsafe 
    -- NOTE: Commented out since we do not want data deleted if a non-integer is specified in the SystemParams table
    -- SET @DaysParamValue = COALESCE(@DaysParamValue, 1000);
    SET @DeleteBatchCount = COALESCE(@DeleteBatchCount, 1000);
    -- define deletion date
    SET @DeletionDate = DATEADD(d, 0-@DaysParamValue, @CurrentDate);

    BEGIN TRY
        -- start archive deletion process
        IF (@DeletionDate IS NOT NULL)
        BEGIN -- NULL check
            SET @RecordsDeleted = 1; -- initialize
            WHILE (@RecordsDeleted > 0) -- loop to break deletions into batches
            BEGIN -- loop
                BEGIN TRANSACTION
                DELETE TOP (@DeleteBatchCount) FROM [' + @DestinationSchemaName + '].[' + [TABLE_NAME] + '] WHERE [RecordCreated] <= @DeletionDate;
                SET @RecordsDeleted = @@ROWCOUNT;
                -- commit the transaction. The CATCH block will not execute
                COMMIT TRANSACTION;

                IF (@RecordsDeleted > 0)
                    RAISERROR(N''%d records deleted from ''''%s'''' archive table'', -1, -1, @RecordsDeleted, @TableName);
                --SET @RecordsDeleted = 0;
            END -- loop
        END -- NULL check
        -- start data archival process
        IF (@ArchiveDate IS NOT NULL)
        BEGIN -- NULL check
            WHILE (1=1) -- loop to break deletions into batches
            BEGIN -- loop
                BEGIN TRANSACTION
                -- move the records in batches and hold on to the IDs
		        INSERT INTO [' + @DestinationSchemaName + '].[' + [TABLE_NAME] + ']
                OUTPUT INSERTED.[' + [COLUMN_NAME] + '] INTO @IDList
			    SELECT TOP(@ArchiveBatchCount) * FROM [' + @SourceSchemaName + '].[' + [TABLE_NAME] + '] WHERE [RecordCreated] <= @ArchiveDate;
		        SET @RecordsMoved = @@ROWCOUNT;
                -- delete records which have been moved
		        DELETE FROM [' + @SourceSchemaName + '].[' + [TABLE_NAME] + '] WHERE [RecordCreated] <= @ArchiveDate
                AND [' + [COLUMN_NAME] + '] IN (SELECT TableID FROM @IDList);
		        SET @RecordsDeleted = @@ROWCOUNT;
                -- check...
                IF (@RecordsDeleted = @RecordsMoved)
		        BEGIN -- rowcount comparison
                    -- commit the transaction. The CATCH block will not execute
                    COMMIT TRANSACTION;
                    IF (@RecordsMoved > 0)
                        RAISERROR(N''%d records archived from table ''''%s'''''', -1, -1, @RecordsMoved, @TableName);
		        END -- rowcount comparison
                ELSE
                    RAISERROR(N''The number of records moved and deleted in table ''''%s'''' do not match.'', 16, 1, @TableName);

                -- clean up
                DELETE FROM @IDList;
                -- exit loop
                IF (@RecordsMoved = 0) AND (@RecordsDeleted = 0) BREAK;

                SET @RecordsDeleted = 0;
                SET @RecordsMoved = 0;
            END -- loop
        END -- NULL check
        -- commit uncommitted transactions (should never happen...)
        IF XACT_STATE() = -1
        BEGIN
            WHILE (@@TRANCOUNT > 0)
            BEGIN
                COMMIT TRANSACTION;
            END
        END
    END TRY
    BEGIN CATCH
        -- transaction is uncommittable
        IF XACT_STATE() = -1
        BEGIN
            WHILE (@@TRANCOUNT > 0)
            BEGIN
                -- rollback all uncommitted transactions
                ROLLBACK TRANSACTION;
            END
        END
        -- log and display error information
        DECLARE @ErrorLogID [int];
        DECLARE @ErrorMessage nvarchar(4000);
        EXEC [dbo].[uspLogError] @ErrorLogID OUTPUT;
        SET @ErrorMessage = (SELECT [ErrorMessage] FROM [dbo].[ErrorLog] WHERE [ErrorLogID] = @ErrorLogID);
        RAISERROR(N''Error %d - %s'', -1, -1, @ErrorLogID, @ErrorMessage);
        RETURN -1;
    END CATCH
END;
'
    FROM cte_MainTables
    ORDER BY [TABLE_NAME] ASC;

    -- procedure to join them all
    WITH cte_MainTables AS (
        SELECT 
            CAST(OBJECT_SCHEMA_NAME(i.object_id, DB_ID()) AS varchar(128)) AS [TABLE_SCHEMA], 
            CAST(OBJECT_NAME(i.object_id) AS varchar(128)) AS [TABLE_NAME]
        FROM sys.index_columns ic
            INNER JOIN sys.indexes i ON (ic.object_id = i.object_id AND ic.index_id = i.index_id)
        WHERE i.object_id > 99 AND i.type = 1
        AND OBJECT_SCHEMA_NAME(i.object_id, DB_ID()) = @SourceSchemaName
    )
    INSERT INTO #ObjectDefinitions (ObjectName, ObjectDrop, ObjectCreate)
    SELECT NULL AS [TABLE_NAME], '
IF OBJECT_ID(N''[' + @DestinationSchemaName + '].[usp_Mantain_Archive]'') IS NOT NULL
DROP PROCEDURE [' + @DestinationSchemaName + '].[usp_Mantain_Archive];
', (
    SELECT '
CREATE PROCEDURE [' + @DestinationSchemaName + '].[usp_Mantain_Archive]
AS
BEGIN
    SET NOCOUNT ON;
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;' + (
        SELECT (
            SELECT '
    EXEC [' + @DestinationSchemaName + '].[usp_Mantain_' + [TABLE_NAME] + '];'
            FROM cte_MainTables p2
            WHERE p2.[TABLE_SCHEMA] = p1.[TABLE_SCHEMA]
            ORDER BY [TABLE_NAME]
            FOR XML PATH(''), TYPE
        ).value('.', 'varchar(max)') AS ObjectNames
        FROM cte_MainTables p1
    GROUP BY [TABLE_SCHEMA]
    ) + 
'
END
');

    -- generate procedures, or output
    IF (UPPER(@Operation) = 'CREATE')
    BEGIN -- CREATE
        DECLARE ScriptCursor CURSOR FOR
            SELECT ObjectDrop, ObjectCreate 
            FROM #ObjectDefinitions 
            ORDER BY (CASE WHEN ObjectName IS NULL THEN 1 ELSE 0 END) ASC;
        DECLARE @ObjectDrop nvarchar(max),
                @ObjectCreate nvarchar(max);
        OPEN ScriptCursor;
        FETCH NEXT FROM ScriptCursor INTO @ObjectDrop, @ObjectCreate;
        WHILE (@@FETCH_STATUS = 0)
        BEGIN
            --PRINT @ObjectDrop;
            EXEC sp_executesql @ObjectDrop;
            --PRINT @ObjectCreate;
            EXEC sp_executesql @ObjectCreate;
            FETCH NEXT FROM ScriptCursor INTO @ObjectDrop, @ObjectCreate;
        END
        CLOSE ScriptCursor;
        DEALLOCATE ScriptCursor;
    END
    ELSE IF (UPPER(@Operation) = 'REPORT')
    BEGIN
        SELECT ObjectName, ObjectDrop, ObjectCreate 
        FROM #ObjectDefinitions 
        ORDER BY (CASE WHEN ObjectName IS NULL THEN 1 ELSE 0 END) ASC
        FOR XML PATH('ObjectDefinitions'), ROOT('Objects');
    END

    -- clean up
    DROP TABLE #ObjectDefinitions;
END
GO


EXEC [SQLMonitor].[dbo].[usp_CreateDataMaintenanceProcs] 'CREATE'
GO

USE [master]
GO
