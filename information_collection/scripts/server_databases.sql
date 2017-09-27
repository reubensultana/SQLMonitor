-- Category: Database Engine Databases
SET NOCOUNT ON;

SELECT 
    CONVERT(nvarchar(128), SERVERPROPERTY('ServerName')) AS ServerName,
    [name] AS [DatabaseName],
    SUSER_SNAME([owner_sid]) AS [DatabaseOwner],
    CONVERT(datetime, [create_date]) AS [CreateDate],
    [compatibility_level] AS [CompatibilityLevel],
    COALESCE([collation_name], '') AS [CollationName], 
    [user_access_desc] AS [UserAccess],
    [is_read_only] AS [IsReadOnly],
    [is_auto_close_on] AS [IsAutoClose],
    [is_auto_shrink_on] AS [IsAutoShrink],
    [state_desc] AS [State],
    [is_in_standby] AS [IsInStandby],
    [recovery_model_desc] AS [RecoveryModel],
    [page_verify_option_desc] AS [PageVerifyOption],
    [is_fulltext_enabled] AS [IsFullTextEnabled],
    [is_trustworthy_on] AS [IsTrustworthy]
FROM sys.databases
ORDER BY database_id ASC;
