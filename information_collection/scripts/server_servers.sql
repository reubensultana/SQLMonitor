-- Category: Database Engine Configuration
SET NOCOUNT ON;

SELECT 
    CONVERT(nvarchar(128), SERVERPROPERTY('ServerName')) AS [ServerName]
    ,[server_id] AS [ServerID]
    ,[name] AS [LinkedServer]
    ,[product] AS [ProductName]
    ,[provider] AS [ProviderName]
    ,[data_source] AS [DataSource]
    ,[provider_string] AS [ProviderString]
    ,[catalog] AS [CatalogConnection]
FROM sys.servers
ORDER BY [server_id] ASC;