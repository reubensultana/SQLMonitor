-- database master key
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'a$tr0ngP@$$w0rdHere!';
GO

-- Create certificate
CREATE CERTIFICATE [SQLServersMonitor] AUTHORIZATION [dbo]
WITH SUBJECT = 'SQL Servers Monitor certificate', 
    START_DATE  = '2022-01-01 00:00:00.000',
    EXPIRY_DATE = '9999-12-31 23:59:59.997';
GO
