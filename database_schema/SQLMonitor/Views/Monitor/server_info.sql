USE [SQLMonitor]
GO

IF OBJECT_ID('[Monitor].[server_info]') IS NOT NULL
DROP VIEW [Monitor].[server_info]
GO

CREATE VIEW [Monitor].[server_info]
AS
SELECT [ServerName]
      ,[ProductVersion]
      ,[ProductLevel]
      ,[ResourceLastUpdateDateTime]
      ,[ResourceVersion]
      ,[ServerAuthentication]
      ,[Edition]
      ,[InstanceName]
      ,[ComputerNamePhysicalNetBIOS]
      ,[BuildClrVersion]
      ,[Collation]
      ,[IsClustered]
      ,[IsFullTextInstalled]
      ,[SqlCharSetName]
      ,[SqlSortOrderName]
      ,[SqlRootPath]
      ,[Product]
      ,[Language]
      ,[Platform]
      ,[LogicalProcessors]
      ,[OSVersion]
      ,[TotalMemoryMB]
      ,[RecordStatus]
      ,[RecordCreated]
FROM [Monitor].[ServerInfo]
--WHERE [RecordStatus] = 'A'
GO
