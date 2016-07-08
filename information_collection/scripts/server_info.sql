-- Category: Database Engine Configuration
SET NOCOUNT ON;

DECLARE @SQLVer TABLE (
	[ID] int,
    [Name]  nvarchar(128),
    [Internal_Value] int,
    [Value] nvarchar(512)
);
INSERT INTO @SQLVer EXEC master.dbo.xp_msver;

-- get sql installation folder from registry
DECLARE @SQLRoot nvarchar(512)

EXEC master.dbo.xp_instance_regread 
    N'HKEY_LOCAL_MACHINE', N'SOFTWARE\Microsoft\MSSQLServer\Setup', 
    N'SQLPath', 
    @SQLRoot OUTPUT;

INSERT INTO @SQLVer(Name, Value) 
VALUES ('SQLRootDir', ISNULL(@SQLRoot, ''));

-- get other options
SELECT
    CONVERT(nvarchar(128), SERVERPROPERTY('ServerName')) AS ServerName,
    CONVERT(nvarchar(128), SERVERPROPERTY('ProductVersion')) AS ProductVersion, 
    CONVERT(nvarchar(128), SERVERPROPERTY('ProductLevel')) AS ProductLevel, 
    CONVERT(datetime, SERVERPROPERTY('ResourceLastUpdateDateTime')) AS ResourceLastUpdateDateTime, 
    CONVERT(nvarchar(128), SERVERPROPERTY('ResourceVersion')) AS ResourceVersion, 
    CASE CONVERT(int, SERVERPROPERTY('IsIntegratedSecurityOnly'))
        WHEN 0 THEN 'SQL Server and Windows' 
        WHEN 1 THEN 'Windows only'
        ELSE 'Error'
    END AS ServerAuthentication, 
    CONVERT(nvarchar(128), SERVERPROPERTY('Edition')) AS Edition, 
    COALESCE(CONVERT(nvarchar(128), SERVERPROPERTY('InstanceName')), '') AS InstanceName, 
    CONVERT(nvarchar(128), SERVERPROPERTY('ComputerNamePhysicalNetBIOS')) AS ComputerNamePhysicalNetBIOS, 
    CONVERT(nvarchar(128), SERVERPROPERTY('BuildClrVersion')) AS BuildClrVersion, 
    CONVERT(nvarchar(128), SERVERPROPERTY('Collation')) AS Collation, 
    CAST(SERVERPROPERTY('IsClustered') AS [bit]) AS IsClustered, 
    CAST(SERVERPROPERTY('IsFullTextInstalled') AS [bit]) AS IsFullTextInstalled, 
    CONVERT(nvarchar(128), SERVERPROPERTY('SqlCharSetName')) AS SqlCharSetName, 
    CONVERT(nvarchar(128), SERVERPROPERTY('SqlSortOrderName')) AS SqlSortOrderName,
    (SELECT Value FROM @SQLVer WHERE Name = N'SQLRootDir') AS [SqlRootPath],
    (SELECT Value FROM @SQLVer WHERE Name = N'ProductName') AS [Product],
    (SELECT Value FROM @SQLVer WHERE Name = N'Language') AS [Language],
    (SELECT Value FROM @SQLVer WHERE Name = N'Platform') AS [Platform],
    (SELECT Internal_Value FROM @SQLVer WHERE Name = N'ProcessorCount') AS [LogicalProcessors],
    (SELECT Value FROM @SQLVer WHERE Name = N'WindowsVersion') AS [OSVersion],
    (SELECT Internal_Value FROM @SQLVer WHERE Name = N'PhysicalMemory') AS [TotalMemoryMB];
