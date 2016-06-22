-- Category: Database Engine Configuration
SET NOCOUNT ON;

SELECT 
    CONVERT(nvarchar(128), SERVERPROPERTY('ServerName')) AS ServerName,
    [configuration_id] AS [ConfigID],
    CAST([name] AS nvarchar(255)) AS [ConfigName],             -- Is this necessary?  Store centrally instead of repeating set for every environment
    CAST([value] AS int) AS [ValueSet],
    CAST([value_in_use] AS int) AS [ValueInUse]
FROM sys.configurations
ORDER BY configuration_id ASC;
