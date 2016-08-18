-- Category: Database Recoverability
SET NOCOUNT ON;
DECLARE @StartDate datetime;
SET @StartDate = CONVERT(datetime, '{0}', 120);
--SET @StartDate = CONVERT(datetime, '1753-01-01 00:00:00', 120);

SELECT
    CONVERT(nvarchar(128), SERVERPROPERTY('ServerName')) AS [ServerName],
    bs.database_name AS [DatabaseName], 
    CASE bs.[type] -- Can be NULL
        WHEN 'D' THEN 'Database'
        WHEN 'I' THEN 'Differential database'
        WHEN 'L' THEN 'Log'
        WHEN 'F' THEN 'File or filegroup'
        WHEN 'G' THEN 'Differential file'
        WHEN 'P' THEN 'Partial'
        WHEN 'Q' THEN 'Differential partial'
        ELSE bs.[type]
    END AS [BackupType], 
    bs.[name] AS [BackupName], 
    bs.[user_name] AS [LoginName], 
    bs.[backup_start_date] AS [StartDate], 
    bs.[backup_finish_date] AS [FinishDate], 
    CAST(((bs.[backup_size]/1024)/1024) AS decimal(15,2)) AS [BackupSizeMB], 
    bs.server_name AS [SourceServer],
    bmf.physical_device_name AS [PhysicalDeviceName], 
    bmf.logical_device_name AS [LogicalDeviceName], 
    bs.expiration_date AS [ExpirationDate], 
    bs.description AS [Description]
FROM msdb.dbo.backupmediafamily bmf
    INNER JOIN msdb.dbo.backupset bs ON bmf.media_set_id = bs.media_set_id
WHERE
    (CONVERT(datetime, bs.backup_start_date, 102) >= @StartDate)
-- remove entries for restores
AND NOT EXISTS ( 
    SELECT 1 FROM msdb.dbo.restorehistory rh
    WHERE rh.[backup_set_id] = bs.[backup_set_id])
ORDER BY [StartDate], [DatabaseName];
