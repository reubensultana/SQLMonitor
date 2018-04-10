param(
	[Parameter(Mandatory=$true)] [String]$ServerName
)

# Clear-Host

# Global params
$ServerInstance = $ServerName
$Database = "master"

$CurrentPath = $PSScriptRoot

# build an array of files, in the order they have to be executed
$filelist = New-Object System.Collections.ArrayList

# NOTE: The "> $null" part is to remove the array item index output
# ----- database schema and initial objects -----
$filelist.Add("\create_database.sql") > $null
$filelist.Add("\create_database_archive.sql") > $null
$filelist.Add("\Tables\dbo\DatabaseLog.sql") > $null
$filelist.Add("\Database Triggers\ddlDatabaseTriggerLog.sql") > $null
$filelist.Add("\Database Triggers\ddlDatabaseTriggerLog_Archive.sql") > $null
$filelist.Add("\Security\schemas.sql") > $null
$filelist.Add("\Security\users.sql") > $null

# ----- tables -----
$filelist.Add("\Tables\dbo\ErrorLog.sql") > $null
$filelist.Add("\Tables\dbo\MonitoredServers.sql") > $null
$filelist.Add("\Tables\dbo\Profile.sql") > $null
$filelist.Add("\Tables\dbo\SystemParams.sql") > $null
$filelist.Add("\Tables\dbo\ReportRecipients.sql") > $null
$filelist.Add("\Tables\dbo\Reports.sql") > $null
# -----
$filelist.Add("\Tables\Monitor\BlitzResults.sql") > $null
$filelist.Add("\Tables\Monitor\DatabaseBackupHistory.sql") > $null
$filelist.Add("\Tables\Monitor\DatabaseConfigurations.sql") > $null
$filelist.Add("\Tables\Monitor\DatabaseTableColumns.sql") > $null
$filelist.Add("\Tables\Monitor\DatabaseTables.sql") > $null
$filelist.Add("\Tables\Monitor\DatabaseUsers.sql") > $null
$filelist.Add("\Tables\Monitor\IndexUsageStats.sql") > $null
$filelist.Add("\Tables\Monitor\MissingIndexStats.sql") > $null
$filelist.Add("\Tables\Monitor\ServerAgentConfig.sql") > $null
$filelist.Add("\Tables\Monitor\ServerAgentJobs.sql") > $null
$filelist.Add("\Tables\Monitor\ServerAgentJobsHistory.sql") > $null
$filelist.Add("\Tables\Monitor\ServerConfigurations.sql") > $null
$filelist.Add("\Tables\Monitor\ServerDatabases.sql") > $null
$filelist.Add("\Tables\Monitor\ServerEndpoints.sql") > $null
$filelist.Add("\Tables\Monitor\ServerErrorLog.sql") > $null
$filelist.Add("\Tables\Monitor\ServerFreeSpace.sql") > $null
$filelist.Add("\Tables\Monitor\ServerInfo.sql") > $null
$filelist.Add("\Tables\Monitor\ServerLogins.sql") > $null
$filelist.Add("\Tables\Monitor\ServerServers.sql") > $null
$filelist.Add("\Tables\Monitor\ServerTriggers.sql") > $null
# -----
$filelist.Add("\Tables\Staging\IndexUsageStats.sql") > $null
$filelist.Add("\Tables\Staging\MissingIndexStats.sql") > $null
# -----
$filelist.Add("\Tables\Archive\DatabaseBackupHistory.sql") > $null
$filelist.Add("\Tables\Archive\DatabaseConfigurations.sql") > $null
$filelist.Add("\Tables\Archive\DatabaseTables.sql") > $null
$filelist.Add("\Tables\Archive\DatabaseUsers.sql") > $null
$filelist.Add("\Tables\Archive\IndexUsageStats.sql") > $null
$filelist.Add("\Tables\Archive\MissingIndexStats.sql") > $null
$filelist.Add("\Tables\Archive\ServerAgentConfig.sql") > $null
$filelist.Add("\Tables\Archive\ServerAgentJobs.sql") > $null
$filelist.Add("\Tables\Archive\ServerAgentJobsHistory.sql") > $null
$filelist.Add("\Tables\Archive\ServerConfigurations.sql") > $null
$filelist.Add("\Tables\Archive\ServerDatabases.sql") > $null
$filelist.Add("\Tables\Archive\ServerEndpoints.sql") > $null
$filelist.Add("\Tables\Archive\ServerErrorLog.sql") > $null
$filelist.Add("\Tables\Archive\ServerFreeSpace.sql") > $null
$filelist.Add("\Tables\Archive\ServerInfo.sql") > $null
$filelist.Add("\Tables\Archive\ServerLogins.sql") > $null
$filelist.Add("\Tables\Archive\ServerServers.sql") > $null
$filelist.Add("\Tables\Archive\ServerTriggers.sql") > $null

# ----- views -----
$filelist.Add("\Views\dbo\vwProfile.sql") > $null
# -----
$filelist.Add("\Views\Monitor\blitz_results.sql") > $null
$filelist.Add("\Views\Monitor\database_backup_history.sql") > $null
$filelist.Add("\Views\Monitor\database_configurations.sql") > $null
$filelist.Add("\Views\Monitor\database_indexusagestats.sql") > $null
$filelist.Add("\Views\Monitor\database_missingindexstats.sql") > $null
$filelist.Add("\Views\Monitor\database_tables.sql") > $null
$filelist.Add("\Views\Monitor\database_table_columns.sql") > $null
$filelist.Add("\Views\Monitor\database_users.sql") > $null
$filelist.Add("\Views\Monitor\server_agentconfig.sql") > $null
$filelist.Add("\Views\Monitor\server_agentjobs.sql") > $null
$filelist.Add("\Views\Monitor\server_agentjobshistory.sql") > $null
$filelist.Add("\Views\Monitor\server_configurations.sql") > $null
$filelist.Add("\Views\Monitor\server_databases.sql") > $null
$filelist.Add("\Views\Monitor\server_endpoints.sql") > $null
$filelist.Add("\Views\Monitor\server_errorlog.sql") > $null
$filelist.Add("\Views\Monitor\server_freespace.sql") > $null
$filelist.Add("\Views\Monitor\server_info.sql") > $null
$filelist.Add("\Views\Monitor\server_logins.sql") > $null
$filelist.Add("\Views\Monitor\server_servers.sql") > $null
$filelist.Add("\Views\Monitor\server_triggers.sql") > $null
# -----
$filelist.Add("\Views\Reporting\vwErrorLog.sql") > $null

# ----- stored procedures -----
$filelist.Add("\Stored Procedures\dbo\uspGetProfile.sql") > $null
$filelist.Add("\Stored Procedures\dbo\uspGetReports.sql") > $null
$filelist.Add("\Stored Procedures\dbo\uspGetServers.sql") > $null
$filelist.Add("\Stored Procedures\dbo\uspLogError.sql") > $null
$filelist.Add("\Stored Procedures\dbo\uspPrintError.sql") > $null
$filelist.Add("\Stored Procedures\dbo\usp_CreateDataMaintenanceProcs.sql") > $null
# -----
$filelist.Add("\Stored Procedures\Reporting\uspBlitzResults.sql") > $null
$filelist.Add("\Stored Procedures\Reporting\uspBlitzResults4Email.sql") > $null
$filelist.Add("\Stored Procedures\Reporting\uspFailedServerAgentJobs.sql") > $null
$filelist.Add("\Stored Procedures\Reporting\uspListAvailableServerRoles.sql") > $null
$filelist.Add("\Stored Procedures\Reporting\uspListAvailableServers.sql") > $null
$filelist.Add("\Stored Procedures\Reporting\uspListDatabaseGrowthTrend.sql") > $null
$filelist.Add("\Stored Procedures\Reporting\uspListDatabaseIndexUsage.sql") > $null
$filelist.Add("\Stored Procedures\Reporting\uspListDatabaseMissingIndex.sql") > $null
$filelist.Add("\Stored Procedures\Reporting\uspListDatabaseTableColumns.sql") > $null
$filelist.Add("\Stored Procedures\Reporting\uspListFailedLogins.sql") > $null
$filelist.Add("\Stored Procedures\Reporting\uspListServerDrives.sql") > $null
$filelist.Add("\Stored Procedures\Reporting\uspListServerFreeSpace.sql") > $null
$filelist.Add("\Stored Procedures\Reporting\uspListServerLogins.sql") > $null
$filelist.Add("\Stored Procedures\Reporting\uspReportServerInformation.sql") > $null
$filelist.Add("\Stored Procedures\Reporting\uspReportSQLBuilds.sql") > $null

# ----- synonyms -----
$filelist.Add("\Synonyms\synonyms.sql") > $null

# ----- initial data set -----
$filelist.Add("\initial_data_set.sql") > $null


# load and run the scripts listed in the array
"{0} : Starting deployment of {1} database scripts to {2}" -f $(Get-Date -Format "HH:mm:ss"), $filelist.Count, $ServerInstance
"{0} : ---------------------------------------------------------------------------" -f $(Get-Date -Format "HH:mm:ss")

ForEach ($script In $filelist) {
    $scriptname = $script.ToString()
    $scriptexecpath = "$($CurrentPath)$($scriptname)"
    $fileExists = Test-Path $scriptexecpath -PathType Leaf
    if ($fileExists) {
        $sql = Get-Content -Path $scriptexecpath -Raw
        "{0} : Running script: {1}" -f $(Get-Date -Format "HH:mm:ss"), $scriptname
        Invoke-Sqlcmd -ServerInstance $ServerInstance -Database $Database -Query $sql
    }
}

"{0} : ---------------------------------------------------------------------------" -f $(Get-Date -Format "HH:mm:ss")
"{0} : All scripts deployed" -f $(Get-Date -Format "HH:mm:ss")

# deallocate variables
$ServerInstance = $null
$Database = $null
$CurrentPath = $null
$filelist = $null
$script = $null
$scriptname = $null
$scriptexecpath = $null
$fileExists = $null
$sql = $null
