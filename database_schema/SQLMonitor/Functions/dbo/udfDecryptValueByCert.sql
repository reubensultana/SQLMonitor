USE [SQLMonitor]
GO

IF OBJECT_ID('[dbo].[udfDecryptValueByCert]') IS NOT NULL
DROP VIEW [dbo].[udfDecryptValueByCert]
GO

CREATE FUNCTION [dbo].[udfDecryptValueByCert] (
    @encryptedText varbinary(8000),
    @certificateName nvarchar(128)
)
RETURNS nvarchar(4000) 
WITH EXEC AS 'SqlMonitorEncryption'
BEGIN
    DECLARE @DecryptedText AS nvarchar(4000)

    SET @DecryptedText = CONVERT(nvarchar(4000), DECRYPTBYCERT(CERT_ID(@certificateName),@encryptedText))

    RETURN (@DecryptedText);
END

GO
