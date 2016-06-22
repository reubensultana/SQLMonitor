cls
# Global params
$ServerInstance = "SQLSRV01,1433"
$Database = "master"

$CurrentPath = $PSScriptRoot

# build an array of files, in the order they have to be executed
$filelist = New-Object System.Collections.ArrayList

# NOTE: The "> $null" part is to remove the array item index output

# 1. create the database
$filelist.Add("\create_database.sql") > $null
# 2. database log objects
$filelist.Add("\Tables\dbo\DatabaseLog.sql") > $null
$filelist.Add("\Database Triggers\ddlDatabaseTriggerLog.sql") > $null
# 3. error logging objects
$filelist.Add("\Tables\dbo\ErrorLog.sql") > $null
$filelist.Add("\Stored Procedures\dbo\uspLogError.sql") > $null
$filelist.Add("\Stored Procedures\dbo\uspPrintError.sql") > $null
# 4 create schema/s
$filelist.Add("\Security\schemas.sql") > $null
# 5 create configuration objects
$filelist.Add("\Tables\dbo\Profile.sql") > $null
$filelist.Add("\Tables\dbo\MonitoredServers.sql") > $null
$filelist.Add("\Stored Procedures\dbo\uspGetProfile.sql") > $null
# 6 server information
$filelist.Add("\Tables\Monitor\ServerInfo.sql") > $null
$filelist.Add("\Views\Monitor\server_info.sql") > $null
# 7 server logins
$filelist.Add("\Tables\Monitor\ServerLogins.sql") > $null
$filelist.Add("\Views\Monitor\server_logins.sql") > $null
# 8 server configuration
$filelist.Add("\Tables\Monitor\ServerConfigurations.sql") > $null
$filelist.Add("\Views\Monitor\server_configurations.sql") > $null
# 9 server databases
$filelist.Add("\Tables\Monitor\ServerDatabases.sql") > $null
$filelist.Add("\Views\Monitor\server_databases.sql") > $null
# 10 server servers
$filelist.Add("\Tables\Monitor\ServerServers.sql") > $null
$filelist.Add("\Views\Monitor\server_servers.sql") > $null
# 11 server triggers
$filelist.Add("\Tables\Monitor\ServerTriggers.sql") > $null
$filelist.Add("\Views\Monitor\server_triggers.sql") > $null
# 12 server triggers
$filelist.Add("\Tables\Monitor\ServerEndpoints.sql") > $null
$filelist.Add("\Views\Monitor\server_endpoints.sql") > $null
# 13 database configurations
$filelist.Add("\Tables\Monitor\DatabaseConfigurations.sql") > $null
$filelist.Add("\Views\Monitor\database_configurations.sql") > $null
# 14 database tables
$filelist.Add("\Tables\Monitor\DatabaseTables.sql") > $null
$filelist.Add("\Views\Monitor\database_tables.sql") > $null
# 15 database users
$filelist.Add("\Tables\Monitor\DatabaseUsers.sql") > $null
$filelist.Add("\Views\Monitor\database_users.sql") > $null
# 16 server error log
$filelist.Add("\Tables\Monitor\ServerErrorLog.sql") > $null
$filelist.Add("\Views\Monitor\server_errorlog.sql") > $null
# 17 view server error log
$filelist.Add("\Views\Reporting\vwErrorLog.sql") > $null

# load and run the scripts listed in the array
"{0} : Starting deployment of {1} database scripts" -f $(Get-Date -Format "HH:mm:ss"), $filelist.Count
"{0} : --------------------------------------------------" -f $(Get-Date -Format "HH:mm:ss")

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

"{0} : --------------------------------------------------" -f $(Get-Date -Format "HH:mm:ss")
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
