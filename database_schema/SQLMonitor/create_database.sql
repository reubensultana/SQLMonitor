USE [master]
GO

SET NOCOUNT ON

DECLARE @device_directory nvarchar(1000);
SET @device_directory = (
	SELECT SUBSTRING([physical_name], 1, CHARINDEX(N'master.mdf', LOWER([physical_name])) - 1)
	FROM sys.master_files WHERE [database_id] = DB_ID('master') AND [file_id] = 1)

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'SQLMonitor')
BEGIN
    DECLARE @sqlcmd nvarchar(2000);
    SET @sqlcmd = N'
CREATE DATABASE [SQLMonitor] ON PRIMARY ( 
    NAME = N''SQLMonitor'', 
    FILENAME = ''' + @device_directory + 'SQLMonitor.mdf'' , 
    SIZE = 5MB , 
    FILEGROWTH = 1MB,
    MAXSIZE = 20MB ),
FILEGROUP TABLES ( 
    NAME = N''SQLMonitor_tables'', 
    FILENAME = ''' + @device_directory + 'SQLMonitor_tables.ndf'' , 
    SIZE = 100MB , 
    FILEGROWTH = 100MB,
    MAXSIZE = 5GB ),
FILEGROUP ARCHIVE ( 
    NAME = N''SQLMonitor_archive'', 
    FILENAME = ''' + @device_directory + 'SQLMonitor_archive.ndf'' , 
    SIZE = 100MB , 
    FILEGROWTH = 100MB,
    MAXSIZE = 5GB )
LOG ON ( 
    NAME = N''SQLMonitor_log'', 
    FILENAME = ''' + @device_directory + 'SQLMonitor_log.ldf'' , 
    SIZE = 100MB , 
    FILEGROWTH = 100MB,
    MAXSIZE = 2GB );';

    EXEC sp_executesql @sqlcmd;

    EXEC sys.sp_dbcmptlevel @dbname=N'SQLMonitor', @new_cmptlevel=120;

    ALTER DATABASE [SQLMonitor] SET RECOVERY SIMPLE;
	
    ALTER DATABASE [SQLMonitor] SET MULTI_USER;

    ALTER DATABASE [SQLMonitor] SET AUTO_CLOSE OFF WITH NO_WAIT;
END
GO

IF NOT EXISTS (SELECT [name] FROM [sys].[databases] WHERE [name] = N'SQLMonitor')
BEGIN
    RAISERROR('Database SQLMonitor does not exist!', 16, 1);
    RETURN;
END
GO


/* ************************************************** */
DECLARE @SQLcmd nvarchar(1000);
DECLARE @SALoginName sysname; -- login name for the 'sa'
SET @SQLcmd = '';
SET @SALoginName = (SELECT [name] FROM sys.sql_logins WHERE sid = 0x01);

SET @SQLcmd = 'ALTER AUTHORIZATION ON DATABASE::[SQLMonitor] TO ' + @SALoginName;

EXEC sp_executesql @SQLcmd;
GO


USE [SQLMonitor]
GO

IF NOT EXISTS (SELECT name FROM sys.filegroups WHERE is_default=1 AND name = N'TABLES') 
    ALTER DATABASE [SQLMonitor] MODIFY FILEGROUP [TABLES] DEFAULT
GO


USE [master]
GO
