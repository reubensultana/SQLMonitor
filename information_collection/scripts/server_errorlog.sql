-- Category: Database Engine Security
SET NOCOUNT ON;
SET DATEFORMAT mdy;

DECLARE @ErrorLogNumber int;
DECLARE @ErrorMsg nvarchar(500);
DECLARE @SQLCmd nvarchar(4000);
DECLARE @StartDate datetime;

SET @ErrorLogNumber = 0;
--SET @ErrorMsg = N'Login failed for user';
SET @ErrorMsg = N'';
SET @SQLCmd = N'';
SET @StartDate = CONVERT(datetime, '{0}', 120);

CREATE TABLE #ErrorLogs (
    [LogNumber] int,
    [LogDate] datetime,
    [LogSize] int
);

CREATE TABLE #ErrorLog (
    [LogDate] datetime,
    [ProcessInfo] nvarchar(128),
    [LogText] varchar(max)
);

INSERT INTO #ErrorLogs
    EXEC sys.sp_enumerrorlogs;

DECLARE L1 CURSOR FOR 
    SELECT [LogNumber] FROM #ErrorLogs WHERE [LogDate] >= @StartDate
    UNION ALL
    SELECT TOP(1) [LogNumber] FROM #ErrorLogs WHERE [LogDate] < @StartDate ORDER BY [LogNumber] ASC;
OPEN L1;
FETCH NEXT FROM L1 INTO @ErrorLogNumber;
WHILE (@@FETCH_STATUS = 0)
BEGIN
    SET @SQLCmd = N'EXEC sys.sp_readerrorlog ' + CAST(@ErrorLogNumber AS nvarchar(10)) + N', 1, ''' + @ErrorMsg + N''';'
    INSERT INTO #ErrorLog 
        EXEC sp_executesql @SQLCmd;

    FETCH NEXT FROM L1 INTO @ErrorLogNumber;
END
CLOSE L1;
DEALLOCATE L1;

SELECT 
    CONVERT(nvarchar(128), SERVERPROPERTY('ServerName')) as [ServerName],
    [LogDate], 
    [ProcessInfo], 
    [LogText]
FROM #ErrorLog
WHERE [LogDate] > @StartDate
AND [LogText] IS NOT NULL
ORDER BY [LogDate] ASC;

DROP TABLE #ErrorLogs;
DROP TABLE #ErrorLog;
