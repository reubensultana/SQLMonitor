-- Category: Database Engine Configuration
SET NOCOUNT ON;

SELECT 
    CONVERT(nvarchar(128), SERVERPROPERTY('ServerName')) AS ServerName,
    [name] AS [EndpointName],
    COALESCE(SUSER_NAME(principal_id), '') AS [Owner], 
    COALESCE([protocol_desc], '') AS [ProtocolDesc],
    COALESCE([type_desc], '') AS [PayloadType],
    COALESCE([state_desc], '') AS [StateDesc],
    [is_admin_endpoint] AS [Is  AdminEndpoint]
FROM sys.endpoints
WHERE [endpoint_id] > 5;
