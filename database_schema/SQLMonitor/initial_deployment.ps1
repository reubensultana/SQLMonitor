[CmdletBinding(DefaultParameterSetName = 'Deployment')]
param(
    [Parameter(
            Mandatory=$true,
            ParameterSetName = 'Deployment',
            HelpMessage="Enter the SQLMonitor repository Instance name.")]
        [ValidateNotNullOrEmpty()]
        [string] $MonitorSqlInstance
    ,
    [Parameter(
            Mandatory=$false,
            ParameterSetName = 'Deployment',
            HelpMessage="Enter the Credential object used to connect to the SQLMonitor repository Instance.")] 
        [PSCredential] $MonitorSqlAuthCredential
    ,
    [Parameter(
            Mandatory=$true,
            ParameterSetName = 'Deployment',
            HelpMessage="Enter the SQLMonitor database name.")]
        [ValidateNotNullOrEmpty()]
        [string] $SqlMonitorDatabaseName = "SQLMonitor"
    ,
    [Parameter(
            Mandatory=$false,
            ParameterSetName = 'Deployment',
            HelpMessage="Enter the SQLMonitor Archive database name.")]
        [string] $SqlMonitorArchiveDatabaseName
    ,
    [Parameter(
            Mandatory=$false, 
            ParameterSetName = 'Version')]
        [Alias("v","ver")]
        [switch] $Version
)
<#
[String] $Username = "sa";
[SecureString] $Password = ConvertTo-SecureString 'P@ssw0rd123!' -AsPlainText -Force
$MyCredential = New-Object System.Management.Automation.PSCredential ($Username, $Password)

NOTE:
To see the password, you'll need to use the Password property on the object that GetNetworkCredential() returns.
> $MyCredential.UserName
> sa
> $MyCredential.Password
> System.Security.SecureString
> $MyCredential.GetNetworkCredential().Password
> P@ssw0rd123!
The password that's returned should be the same password that you provided early to the PSCredential constructor.
#>

if ($true -eq $Version) {
    Write-Output "SqlMonitor Version 2.0.0"
    Write-Output $("© Reuben Sultana - {0}" -f $(Get-Date -Format "yyyy"))
    return
}

# check if dbatools is installed
if ($(Get-InstalledModule -Name dbatools -ErrorAction SilentlyContinue).Name -ne "dbatools") { 
    Write-Error "DBA Tools is not installed. Please install it as explained in the deployment instructions."
    return
}

# import modules - assuming that they must be installed as part of the project prerequisites
if ($(Get-Module -Name dbatools).Name -ne "dbatools") { Import-Module -Name dbatools }

# get script file location
$CurrentPath = [System.IO.Path]::GetDirectoryName($myInvocation.MyCommand.Definition)

[boolean] $UseSeperateArchiveDatabase = $true
if ([string]::IsNullOrEmpty($SqlMonitorArchiveDatabaseName)) {
    $UseSeperateArchiveDatabase = $false
    $SqlMonitorArchiveDatabaseName = $SqlMonitorDatabaseName
}

# check if the SqlMonitor database (and SqlMonitorArchive) database/s exist
if ([string]::IsNullOrEmpty($(Get-DbaDatabase -SqlInstance $MonitorSqlInstance -SqlCredential $MonitorSqlAuthCredential -Database $SqlMonitorDatabaseName).Name)) {
    Write-Error "The SqlMonitor database does not exist. Please create it using the supplied 'create_database.sql' script."
    return
}
if ($true -eq $UseSeperateArchiveDatabase) {
    if ([string]::IsNullOrEmpty($(Get-DbaDatabase -SqlInstance $MonitorSqlInstance -SqlCredential $MonitorSqlAuthCredential -Database $SqlMonitorArchiveDatabaseName).Name)) {
        Write-Error "The SqlMonitor Archive database does not exist. Please create it using the supplied 'create_database_archive.sql' script."
        return
    }
}

# this is more of a constatnt than a variable
[string] $MasterDatabaseName = "master"

# build an array of files, in the order they have to be executed
class ScriptFile {
    [int] $ScriptNumber = 0
    [string] $DatabaseName = ''
    [string] $ScriptFile = ''

    ScriptFile(
            [string] $DatabaseName, 
            [int] $ScriptNumber, 
            [string] $ScriptFile
        ) {
        $this.DatabaseName = $DatabaseName
        $this.ScriptNumber = $ScriptNumber
        $this.ScriptFile = $ScriptFile
    }
}
    
class DatabaseScripts {
    [int]$ScriptNumberCounter = 0
    [string]$DatabaseName = ''
    [System.Collections.ArrayList]$Scripts = @()

    [int]AddScript([string]$DatabaseName, [string]$ScriptFile) {
        $newScriptNumber = $this.GetNewScriptNumber()
        $newScript = [ScriptFile]::new($DatabaseName, $newScriptNumber, $ScriptFile)

        $this.Scripts.Add($newScript)

        return $newScriptNumber
    }

    [int]GetScriptName([int]$ScriptNumber) {
        return $this.Scripts[$ScriptNumber-1]
    }

    [int]GetNewScriptNumber() {
        return $this.ScriptNumberCounter += 1
    }
}

$FileList = [DatabaseScripts]::new()

# NOTE: The "... > $null" part is to remove the array item index output; performs better than "... | Out-Null"
# ----- database schema and initial objects -----
# $FileList.AddScript($MasterDatabaseName, "\create_database.sql") > $null
# $FileList.AddScript($MasterDatabaseName, "\create_database_archive.sql") > $null

# the code for the next two files is identical to the archive database, so only one code-base is provided
$FileList.AddScript($SqlMonitorDatabaseName, "\Tables\dbo\DatabaseLog.sql") > $null
$FileList.AddScript($SqlMonitorDatabaseName, "\Database Triggers\ddlDatabaseTriggerLog.sql") > $null

$FileList.AddScript($SqlMonitorDatabaseName, "\Security\schemas.sql") > $null
$FileList.AddScript($SqlMonitorDatabaseName, "\Security\encryption.sql") > $null
$FileList.AddScript($SqlMonitorDatabaseName, "\Security\users.sql") > $null
$FileList.AddScript($SqlMonitorDatabaseName, "\Functions\dbo\udfDecryptValueByCert.sql") > $null

# the code for the next two files is identical to the main database, so only one code-base is provided
$FileList.AddScript($SqlMonitorArchiveDatabaseName, "\Tables\dbo\DatabaseLog.sql") > $null
$FileList.AddScript($SqlMonitorArchiveDatabaseName, "\Database Triggers\ddlDatabaseTriggerLog.sql") > $null

$FileList.AddScript($SqlMonitorArchiveDatabaseName, "\Security\schemas_archive.sql") > $null
$FileList.AddScript($SqlMonitorArchiveDatabaseName, "\Security\users_archive.sql") > $null

# ----- tables -----
$FileList.AddScript($SqlMonitorDatabaseName, "\Tables\dbo\ErrorLog.sql") > $null
$FileList.AddScript($SqlMonitorDatabaseName, "\Tables\dbo\MonitoredServers.sql") > $null
$FileList.AddScript($SqlMonitorDatabaseName, "\Tables\dbo\Profile.sql") > $null
$FileList.AddScript($SqlMonitorDatabaseName, "\Tables\dbo\SystemParams.sql") > $null
$FileList.AddScript($SqlMonitorDatabaseName, "\Tables\dbo\ReportRecipients.sql") > $null
$FileList.AddScript($SqlMonitorDatabaseName, "\Tables\dbo\Reports.sql") > $null
$FileList.AddScript($SqlMonitorDatabaseName, "\Tables\dbo\ReportSubscriptions.sql") > $null
# -----
$FileList.AddScript($SqlMonitorDatabaseName, "\Tables\Monitor\BlitzResults.sql") > $null
$FileList.AddScript($SqlMonitorDatabaseName, "\Tables\Monitor\DatabaseBackupHistory.sql") > $null
$FileList.AddScript($SqlMonitorDatabaseName, "\Tables\Monitor\DatabaseConfigurations.sql") > $null
$FileList.AddScript($SqlMonitorDatabaseName, "\Tables\Monitor\DatabaseTableColumns.sql") > $null
$FileList.AddScript($SqlMonitorDatabaseName, "\Tables\Monitor\DatabaseTables.sql") > $null
$FileList.AddScript($SqlMonitorDatabaseName, "\Tables\Monitor\DatabaseUsers.sql") > $null
$FileList.AddScript($SqlMonitorDatabaseName, "\Tables\Monitor\IndexUsageStats.sql") > $null
$FileList.AddScript($SqlMonitorDatabaseName, "\Tables\Monitor\MissingIndexStats.sql") > $null
$FileList.AddScript($SqlMonitorDatabaseName, "\Tables\Monitor\ServerAgentConfig.sql") > $null
$FileList.AddScript($SqlMonitorDatabaseName, "\Tables\Monitor\ServerAgentJobs.sql") > $null
$FileList.AddScript($SqlMonitorDatabaseName, "\Tables\Monitor\ServerAgentJobsHistory.sql") > $null
$FileList.AddScript($SqlMonitorDatabaseName, "\Tables\Monitor\ServerConfigurations.sql") > $null
$FileList.AddScript($SqlMonitorDatabaseName, "\Tables\Monitor\ServerDatabases.sql") > $null
$FileList.AddScript($SqlMonitorDatabaseName, "\Tables\Monitor\ServerEndpoints.sql") > $null
$FileList.AddScript($SqlMonitorDatabaseName, "\Tables\Monitor\ServerErrorLog.sql") > $null
$FileList.AddScript($SqlMonitorDatabaseName, "\Tables\Monitor\ServerFreeSpace.sql") > $null
$FileList.AddScript($SqlMonitorDatabaseName, "\Tables\Monitor\ServerInfo.sql") > $null
$FileList.AddScript($SqlMonitorDatabaseName, "\Tables\Monitor\ServerLogins.sql") > $null
$FileList.AddScript($SqlMonitorDatabaseName, "\Tables\Monitor\ServerServers.sql") > $null
$FileList.AddScript($SqlMonitorDatabaseName, "\Tables\Monitor\ServerTriggers.sql") > $null
# -----
<#
$FileList.AddScript($SqlMonitorDatabaseName, "\Tables\Staging\IndexUsageStats.sql") > $null
#$FileList.AddScript($SqlMonitorDatabaseName, "\Tables\Staging\MissingIndexStats.sql") > $null
#>
# -----
$FileList.AddScript($SqlMonitorDatabaseName, "\Tables\Staging\BlitzResults.sql") > $null
$FileList.AddScript($SqlMonitorDatabaseName, "\Tables\Staging\DatabaseBackupHistory.sql") > $null
$FileList.AddScript($SqlMonitorDatabaseName, "\Tables\Staging\DatabaseConfigurations.sql") > $null
$FileList.AddScript($SqlMonitorDatabaseName, "\Tables\Staging\DatabaseTableColumns.sql") > $null
$FileList.AddScript($SqlMonitorDatabaseName, "\Tables\Staging\DatabaseTables.sql") > $null
$FileList.AddScript($SqlMonitorDatabaseName, "\Tables\Staging\DatabaseUsers.sql") > $null
$FileList.AddScript($SqlMonitorDatabaseName, "\Tables\Staging\DatabaseIndexUsageStats.sql") > $null
$FileList.AddScript($SqlMonitorDatabaseName, "\Tables\Staging\DatabaseMissingIndexStats.sql") > $null
$FileList.AddScript($SqlMonitorDatabaseName, "\Tables\Staging\ServerAgentConfig.sql") > $null
$FileList.AddScript($SqlMonitorDatabaseName, "\Tables\Staging\ServerAgentJobs.sql") > $null
$FileList.AddScript($SqlMonitorDatabaseName, "\Tables\Staging\ServerAgentJobsHistory.sql") > $null
$FileList.AddScript($SqlMonitorDatabaseName, "\Tables\Staging\ServerConfigurations.sql") > $null
$FileList.AddScript($SqlMonitorDatabaseName, "\Tables\Staging\ServerDatabases.sql") > $null
$FileList.AddScript($SqlMonitorDatabaseName, "\Tables\Staging\ServerEndpoints.sql") > $null
$FileList.AddScript($SqlMonitorDatabaseName, "\Tables\Staging\ServerErrorLog.sql") > $null
$FileList.AddScript($SqlMonitorDatabaseName, "\Tables\Staging\ServerFreeSpace.sql") > $null
$FileList.AddScript($SqlMonitorDatabaseName, "\Tables\Staging\ServerInfo.sql") > $null
$FileList.AddScript($SqlMonitorDatabaseName, "\Tables\Staging\ServerLogins.sql") > $null
$FileList.AddScript($SqlMonitorDatabaseName, "\Tables\Staging\ServerMSB.sql") > $null
$FileList.AddScript($SqlMonitorDatabaseName, "\Tables\Staging\ServerServers.sql") > $null
$FileList.AddScript($SqlMonitorDatabaseName, "\Tables\Staging\ServerTriggers.sql") > $null

# -----
$FileList.AddScript($SqlMonitorArchiveDatabaseName, "\Tables\Archive\DatabaseBackupHistory.sql") > $null
$FileList.AddScript($SqlMonitorArchiveDatabaseName, "\Tables\Archive\DatabaseConfigurations.sql") > $null
$FileList.AddScript($SqlMonitorArchiveDatabaseName, "\Tables\Archive\DatabaseTables.sql") > $null
$FileList.AddScript($SqlMonitorArchiveDatabaseName, "\Tables\Archive\DatabaseUsers.sql") > $null
$FileList.AddScript($SqlMonitorArchiveDatabaseName, "\Tables\Archive\IndexUsageStats.sql") > $null
$FileList.AddScript($SqlMonitorArchiveDatabaseName, "\Tables\Archive\MissingIndexStats.sql") > $null
$FileList.AddScript($SqlMonitorArchiveDatabaseName, "\Tables\Archive\ServerAgentConfig.sql") > $null
$FileList.AddScript($SqlMonitorArchiveDatabaseName, "\Tables\Archive\ServerAgentJobs.sql") > $null
$FileList.AddScript($SqlMonitorArchiveDatabaseName, "\Tables\Archive\ServerAgentJobsHistory.sql") > $null
$FileList.AddScript($SqlMonitorArchiveDatabaseName, "\Tables\Archive\ServerConfigurations.sql") > $null
$FileList.AddScript($SqlMonitorArchiveDatabaseName, "\Tables\Archive\ServerDatabases.sql") > $null
$FileList.AddScript($SqlMonitorArchiveDatabaseName, "\Tables\Archive\ServerEndpoints.sql") > $null
$FileList.AddScript($SqlMonitorArchiveDatabaseName, "\Tables\Archive\ServerErrorLog.sql") > $null
$FileList.AddScript($SqlMonitorArchiveDatabaseName, "\Tables\Archive\ServerFreeSpace.sql") > $null
$FileList.AddScript($SqlMonitorArchiveDatabaseName, "\Tables\Archive\ServerInfo.sql") > $null
$FileList.AddScript($SqlMonitorArchiveDatabaseName, "\Tables\Archive\ServerLogins.sql") > $null
$FileList.AddScript($SqlMonitorArchiveDatabaseName, "\Tables\Archive\ServerServers.sql") > $null
$FileList.AddScript($SqlMonitorArchiveDatabaseName, "\Tables\Archive\ServerTriggers.sql") > $null

# ----- views -----
$FileList.AddScript($SqlMonitorDatabaseName, "\Views\dbo\vwProfile.sql") > $null
$FileList.AddScript($SqlMonitorDatabaseName, "\Views\dbo\vwMonitoredServers.sql") > $null
# -----
$FileList.AddScript($SqlMonitorDatabaseName, "\Views\Reporting\vwErrorLog.sql") > $null

# ----- stored procedures -----
$FileList.AddScript($SqlMonitorDatabaseName, "\Stored Procedures\dbo\uspGetProfile.sql") > $null
$FileList.AddScript($SqlMonitorDatabaseName, "\Stored Procedures\dbo\uspGetReports.sql") > $null
$FileList.AddScript($SqlMonitorDatabaseName, "\Stored Procedures\dbo\uspGetServers.sql") > $null
$FileList.AddScript($SqlMonitorDatabaseName, "\Stored Procedures\dbo\uspLogError.sql") > $null
$FileList.AddScript($SqlMonitorDatabaseName, "\Stored Procedures\dbo\uspPrintError.sql") > $null
$FileList.AddScript($SqlMonitorDatabaseName, "\Stored Procedures\dbo\usp_CreateDataMaintenanceProcs.sql") > $null
# -----
$FileList.AddScript($SqlMonitorDatabaseName, "\Stored Procedures\Reporting\uspBlitzResults.sql") > $null
$FileList.AddScript($SqlMonitorDatabaseName, "\Stored Procedures\Reporting\uspBlitzResults4Email.sql") > $null
$FileList.AddScript($SqlMonitorDatabaseName, "\Stored Procedures\Reporting\uspFailedServerAgentJobs.sql") > $null
$FileList.AddScript($SqlMonitorDatabaseName, "\Stored Procedures\Reporting\uspListAvailableServerRoles.sql") > $null
$FileList.AddScript($SqlMonitorDatabaseName, "\Stored Procedures\Reporting\uspListAvailableServers.sql") > $null
$FileList.AddScript($SqlMonitorDatabaseName, "\Stored Procedures\Reporting\uspListDatabaseGrowthTrend.sql") > $null

$FileList.AddScript($SqlMonitorDatabaseName, "\Stored Procedures\Reporting\uspListDatabaseIndexUsage.sql") > $null
$FileList.AddScript($SqlMonitorDatabaseName, "\Stored Procedures\Reporting\uspListDatabaseMissingIndex.sql") > $null
$FileList.AddScript($SqlMonitorDatabaseName, "\Stored Procedures\Reporting\uspListDatabaseTableColumns.sql") > $null
$FileList.AddScript($SqlMonitorDatabaseName, "\Stored Procedures\Reporting\uspListFailedLogins.sql") > $null
$FileList.AddScript($SqlMonitorDatabaseName, "\Stored Procedures\Reporting\uspListServerDrives.sql") > $null
$FileList.AddScript($SqlMonitorDatabaseName, "\Stored Procedures\Reporting\uspListServerFreeSpace.sql") > $null
$FileList.AddScript($SqlMonitorDatabaseName, "\Stored Procedures\Reporting\uspListServerLogins.sql") > $null
$FileList.AddScript($SqlMonitorDatabaseName, "\Stored Procedures\Reporting\uspReportServerInformation.sql") > $null
$FileList.AddScript($SqlMonitorDatabaseName, "\Stored Procedures\Reporting\uspReportSQLBuilds.sql") > $null

# ----- synonyms -----
#$FileList.AddScript($SqlMonitorDatabaseName, "\Synonyms\synonyms.sql") > $null

# ----- initial data set -----
$FileList.AddScript($SqlMonitorDatabaseName, "\Data\MonitoredServers.sql") > $null
$FileList.AddScript($SqlMonitorDatabaseName, "\Data\Profile.sql") > $null
$FileList.AddScript($SqlMonitorDatabaseName, "\Data\ReportRecipients.sql") > $null
$FileList.AddScript($SqlMonitorDatabaseName, "\Data\Reports.sql") > $null
$FileList.AddScript($SqlMonitorDatabaseName, "\Data\ReportSubscriptions.sql") > $null
$FileList.AddScript($SqlMonitorDatabaseName, "\Data\SystemParams.sql") > $null

# load and run the scripts listed in the array
"{0} : Starting deployment of {1} database scripts to {2}" -f $(Get-Date -Format "HH:mm:ss"), $FileList.Count, $MonitorSqlInstance
"{0} : ---------------------------------------------------------------------------" -f $(Get-Date -Format "HH:mm:ss")

foreach ($ScriptObj in ($FileList.Scripts | Sort-Object -Property ScriptNumber)) {
    $ScriptFile = $ScriptObj.ScriptFile
    $TargetDatabase = $ScriptObj.DatabaseName
    $ScriptExecPath = "$($CurrentPath)$($ScriptFile)"
    if ($(Test-Path $ScriptExecPath -PathType Leaf)) {
        # [string] $SqlCmd = $(Get-Content -Path $ScriptExecPath -Raw)
        "{0} : Running script: '{1}' for the '{2}' database" -f $(Get-Date -Format "HH:mm:ss"), $ScriptFile, $TargetDatabase
        try { 
            # use Windows Authentication
            if ($null -eq $MonitorSqlAuthCredential) { Invoke-DbaQuery -SqlInstance $MonitorSqlInstance -Database $TargetDatabase -File $ScriptExecPath } #-EnableException -ErrorAction Stop }
            # use SQL Authentication
            else { Invoke-DbaQuery -SqlInstance $MonitorSqlInstance -Database $TargetDatabase -SqlCredential $MonitorSqlAuthCredential -File $ScriptExecPath } #-EnableException -ErrorAction Stop }
        }
        catch { break } # exit the ForEach on error
    }
}

"{0} : ---------------------------------------------------------------------------" -f $(Get-Date -Format "HH:mm:ss")
"{0} : Script execution complete" -f $(Get-Date -Format "HH:mm:ss")

if ($true -eq $UseSeperateArchiveDatabase) {
    Write-Warning "Archive objects have been created in a separate SqlMonitor Archive database. 
Please create Synonyms using the supplied '\Synonyms\synonyms.sql' script to ensure that the functionality remains intact."
}

# deallocate variables
$MasterDatabaseName = $null
$CurrentPath = $null
$FileList = $null
$ScriptObj = $null
$ScriptExecPath = $null
