USE [master]
GO

SET NOCOUNT ON

DECLARE @device_directory nvarchar(1000);
SET @device_directory = (
	SELECT SUBSTRING([physical_name], 1, CHARINDEX(N'master.mdf', LOWER([physical_name])) - 1)
	FROM sys.master_files WHERE [database_id] = DB_ID('master') AND [file_id] = 1)

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'SQLMonitorArchive')
BEGIN
    DECLARE @sqlcmd nvarchar(2000);
    SET @sqlcmd = N'
CREATE DATABASE [SQLMonitorArchive] ON PRIMARY ( 
    NAME = N''SQLMonitorArchive'', 
    FILENAME = ''' + @device_directory + 'SQLMonitorArchive.mdf'' , 
    SIZE = 5MB , 
    FILEGROWTH = 1MB,
    MAXSIZE = 20MB ),
FILEGROUP TABLES ( 
    NAME = N''SQLMonitorArchive_tables'', 
    FILENAME = ''' + @device_directory + 'SQLMonitorArchive_tables.ndf'' , 
    SIZE = 100MB , 
    FILEGROWTH = 100MB,
    MAXSIZE = 5GB )
LOG ON ( 
    NAME = N''SQLMonitorArchive_log'', 
    FILENAME = ''' + @device_directory + 'SQLMonitorArchive_log.ldf'' , 
    SIZE = 100MB , 
    FILEGROWTH = 100MB,
    MAXSIZE = 2GB );';

    EXEC sp_executesql @sqlcmd;

    EXEC sys.sp_dbcmptlevel @dbname=N'SQLMonitorArchive', @new_cmptlevel=120;

    ALTER DATABASE [SQLMonitorArchive] SET RECOVERY SIMPLE;
	
    ALTER DATABASE [SQLMonitorArchive] SET MULTI_USER;

    ALTER DATABASE [SQLMonitorArchive] SET AUTO_CLOSE OFF WITH NO_WAIT;
END
GO

IF NOT EXISTS (SELECT [name] FROM [sys].[databases] WHERE [name] = N'SQLMonitorArchive')
BEGIN
    RAISERROR('Database SQLMonitorArchive does not exist!', 16, 1);
    RETURN;
END
GO


/* ************************************************** */
DECLARE @SQLcmd nvarchar(1000);
DECLARE @SALoginName sysname; -- login name for the 'sa'
SET @SQLcmd = '';
SET @SALoginName = (SELECT [name] FROM sys.sql_logins WHERE sid = 0x01);

SET @SQLcmd = 'ALTER AUTHORIZATION ON DATABASE::[SQLMonitorArchive] TO ' + @SALoginName;

EXEC sp_executesql @SQLcmd;
GO


USE [SQLMonitorArchive]
GO

IF NOT EXISTS (SELECT name FROM sys.filegroups WHERE is_default=1 AND name = N'TABLES') 
    ALTER DATABASE [SQLMonitorArchive] MODIFY FILEGROUP [TABLES] DEFAULT
GO


USE [master]
GO
