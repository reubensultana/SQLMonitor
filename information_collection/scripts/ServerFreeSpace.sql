SET NOCOUNT ON;

CREATE TABLE #FreeSpace(
    Drive   char(1), 
    FreeMB int
);

INSERT INTO #FreeSpace
    EXEC master..xp_fixeddrives;

SELECT 
    CONVERT(varchar(100), SERVERPROPERTY('Servername')) AS [ServerName], 
    [Drive], 
    [FreeMB]
FROM #FreeSpace;

DROP TABLE #FreeSpace;
