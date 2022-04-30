IF NOT EXISTS(SELECT 1 FROM sys.schemas WHERE name = 'Archive')
    EXEC sp_executesql N'CREATE SCHEMA [Archive] AUTHORIZATION [dbo];';
GO
