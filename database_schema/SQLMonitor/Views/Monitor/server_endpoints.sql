USE [SQLMonitor]
GO

IF OBJECT_ID('[Monitor].[server_endpoints]') IS NOT NULL
DROP VIEW [Monitor].[server_endpoints]
GO

CREATE VIEW [Monitor].[server_endpoints]
AS
SELECT [ServerName]
    ,[EndpointName]
    ,[Owner]
    ,[ProtocolDesc]
    ,[PayloadType]
    ,[StateDesc]
    ,[IsAdminEndpoint]
    ,[RecordStatus]
    ,[RecordCreated]
FROM [Monitor].[ServerEndpoints]
--WHERE [RecordStatus] = 'A'
GO
