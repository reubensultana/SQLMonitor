USE [SQLMonitor]
GO

IF OBJECT_ID(N'[Reporting].[uspListAvailableServerRoles]') IS NOT NULL
DROP PROCEDURE [Reporting].[uspListAvailableServerRoles]
GO

CREATE PROCEDURE [Reporting].[uspListAvailableServerRoles] 
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON;
    SELECT 
        '***** Select All ***** ' AS [RoleName], 
        '%' AS [RoleNameValue],
        NULL AS [PrincipalID]
    UNION ALL
    SELECT 
        [name] AS [RoleName], 
        [name] AS [RoleNameValue],
        sp.principal_id AS [PrincipalID]
    FROM [master].sys.server_principals sp
    WHERE sp.type = 'R' AND sp.is_fixed_role = 1
    ORDER BY [PrincipalID];
END
GO

-- EXEC [SQLMonitor].[Reporting].[uspListAvailableServerRoles] 


USE [master]
GO
