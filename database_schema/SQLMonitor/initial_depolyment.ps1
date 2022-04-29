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
        [PSCredential] $SQLCredential
    ,
    [Parameter(
            Mandatory=$false,
            ParameterSetName = 'Deployment',
            HelpMessage="Choose whether to create the SqlMonitor database.")] 
        [switch] $CreateSqlMonitorDatabase
    ,
    [Parameter(
            Mandatory=$false,
            ParameterSetName = 'Deployment',
            HelpMessage="Choose whether to create the SqlMonitor Archive database.")] 
        [switch] $CreateSqlMonitorArchiveDatabase
    ,
    [Parameter(
            Mandatory=$false, 
            ParameterSetName = 'Version')]
        [Alias("v","ver")]
        [switch] $Version
)

DynamicParam {
    if ($true -eq $CreateSqlMonitorDatabase) {
        # Define parameter attributes
        $paramAttributes = New-Object -Type System.Management.Automation.ParameterAttribute
        $paramAttributes.Mandatory = $true
        $paramAttributes.ParameterSetName = 'Deployment'
        $paramAttributes.HelpMessage="Enter the name which will be used for the SqlMonitor database."

        $paramAttributesCollect = New-Object -Type System.Collections.ObjectModel.Collection[System.Attribute]
        $paramAttributesCollect.Add($paramAttributes)

        $dynParam1 = New-Object -Type System.Management.Automation.RuntimeDefinedParameter("SqlMonitorDatabaseName", [string], $paramAttributesCollect)

        $paramDictionary = New-Object -Type System.Management.Automation.RuntimeDefinedParameterDictionary
        $paramDictionary.Add("SqlMonitorDatabaseName", $dynParam1)
        return $paramDictionary
    }

    if ($true -eq $CreateSqlMonitorArchiveDatabase) {
        # Define parameter attributes
        $paramAttributes = New-Object -Type System.Management.Automation.ParameterAttribute
        $paramAttributes.Mandatory = $true
        $paramAttributes.ParameterSetName = 'Deployment'
        $paramAttributes.HelpMessage="Enter the name which will be used for the SqlMonitor Archive database."

        $paramAttributesCollect = New-Object -Type System.Collections.ObjectModel.Collection[System.Attribute]
        $paramAttributesCollect.Add($paramAttributes)

        $dynParam1 = New-Object -Type System.Management.Automation.RuntimeDefinedParameter("SqlMonitorArchiveDatabaseName", [string], $paramAttributesCollect)

        $paramDictionary = New-Object -Type System.Management.Automation.RuntimeDefinedParameterDictionary
        $paramDictionary.Add("SqlMonitorArchiveDatabaseName", $dynParam1)
        return $paramDictionary
    }
}
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

# With the dynamic parameter defined, here’s one thing the Microsoft documentation doesn’t specify: the rest of your code has to be in begin/process/end blocks.
begin {
    if ($true -eq $Version) {
        Write-Output "SqlMonitor Version 2.0.0"
        Write-Output $("© Reuben Sultana - {0}" -f $(Get-Date -Format "yyyy"))
        return
    }
    # Global params
    if ($true -eq $CreateSqlMonitorDatabase) { 
        [string] $SqlMonitorDatabaseName = $PSBoundParameters['SqlMonitorDatabaseName']
    }
    if ($true -eq $CreateSqlMonitorArchiveDatabase) {
        [string] $SqlMonitorArchiveDatabaseName = $PSBoundParameters['SqlMonitorArchiveDatabaseName']
    }

    [string] $Database = "master"

    $CurrentPath = $PSScriptRoot

    # build an array of files, in the order they have to be executed
    $filelist = @(
    # ----- database schema and initial objects -----
        "\create_database.sql"
        ,"\create_database_archive.sql"
        ,"\Tables\dbo\DatabaseLog.sql"
        ,"\Tables\dbo\DatabaseLog_Archive.sql"
        ,"\Database Triggers\ddlDatabaseTriggerLog.sql"
        ,"\Database Triggers\ddlDatabaseTriggerLog_Archive.sql"
        ,"\Security\schemas.sql"
        ,"\Security\encryption.sql"
        ,"\Security\users.sql"
        ,"\Functions\dbo\udfDecryptValueByCert.sql"
    # ----- tables -----
        ,"\Tables\dbo\ErrorLog.sql"
        ,"\Tables\dbo\MonitoredServers.sql"
        ,"\Tables\dbo\Profile.sql"
        ,"\Tables\dbo\SystemParams.sql"
        ,"\Tables\dbo\ReportRecipients.sql"
        ,"\Tables\dbo\Reports.sql"
        ,"\Tables\dbo\ReportSubscriptions.sql"
    # -----
        ,"\Tables\Monitor\BlitzResults.sql"
        ,"\Tables\Monitor\DatabaseBackupHistory.sql"
        ,"\Tables\Monitor\DatabaseConfigurations.sql"
        ,"\Tables\Monitor\DatabaseTableColumns.sql"
        ,"\Tables\Monitor\DatabaseTables.sql"
        ,"\Tables\Monitor\DatabaseUsers.sql"
        ,"\Tables\Monitor\DatabaseIndexUsageStats.sql"
        ,"\Tables\Monitor\DatabaseMissingIndexStats.sql"
        ,"\Tables\Monitor\ServerAgentConfig.sql"
        ,"\Tables\Monitor\ServerAgentJobs.sql"
        ,"\Tables\Monitor\ServerAgentJobsHistory.sql"
        ,"\Tables\Monitor\ServerConfigurations.sql"
        ,"\Tables\Monitor\ServerDatabases.sql"
        ,"\Tables\Monitor\ServerEndpoints.sql"
        ,"\Tables\Monitor\ServerErrorLog.sql"
        ,"\Tables\Monitor\ServerFreeSpace.sql"
        ,"\Tables\Monitor\ServerInfo.sql"
        ,"\Tables\Monitor\ServerLogins.sql"
        ,"\Tables\Monitor\ServerMSB.sql"
        ,"\Tables\Monitor\ServerServers.sql"
        ,"\Tables\Monitor\ServerTriggers.sql"
    # -----
        ,"\Tables\Staging\BlitzResults.sql"
        ,"\Tables\Staging\DatabaseBackupHistory.sql"
        ,"\Tables\Staging\DatabaseConfigurations.sql"
        ,"\Tables\Staging\DatabaseTableColumns.sql"
        ,"\Tables\Staging\DatabaseTables.sql"
        ,"\Tables\Staging\DatabaseUsers.sql"
        ,"\Tables\Staging\DatabaseIndexUsageStats.sql"
        ,"\Tables\Staging\DatabaseMissingIndexStats.sql"
        ,"\Tables\Staging\ServerAgentConfig.sql"
        ,"\Tables\Staging\ServerAgentJobs.sql"
        ,"\Tables\Staging\ServerAgentJobsHistory.sql"
        ,"\Tables\Staging\ServerConfigurations.sql"
        ,"\Tables\Staging\ServerDatabases.sql"
        ,"\Tables\Staging\ServerEndpoints.sql"
        ,"\Tables\Staging\ServerErrorLog.sql"
        ,"\Tables\Staging\ServerFreeSpace.sql"
        ,"\Tables\Staging\ServerInfo.sql"
        ,"\Tables\Staging\ServerLogins.sql"
        ,"\Tables\Staging\ServerMSB.sql"
        ,"\Tables\Staging\ServerServers.sql"
        ,"\Tables\Staging\ServerTriggers.sql"
    # -----
        ,"\Tables\Archive\DatabaseBackupHistory.sql"
        ,"\Tables\Archive\DatabaseConfigurations.sql"
        ,"\Tables\Archive\DatabaseTables.sql"
        ,"\Tables\Archive\DatabaseUsers.sql"
        ,"\Tables\Archive\DatabaseIndexUsageStats.sql"
        ,"\Tables\Archive\DatabaseMissingIndexStats.sql"
        ,"\Tables\Archive\ServerAgentConfig.sql"
        ,"\Tables\Archive\ServerAgentJobs.sql"
        ,"\Tables\Archive\ServerAgentJobsHistory.sql"
        ,"\Tables\Archive\ServerConfigurations.sql"
        ,"\Tables\Archive\ServerDatabases.sql"
        ,"\Tables\Archive\ServerEndpoints.sql"
        ,"\Tables\Archive\ServerErrorLog.sql"
        ,"\Tables\Archive\ServerFreeSpace.sql"
        ,"\Tables\Archive\ServerInfo.sql"
        ,"\Tables\Archive\ServerLogins.sql"
        ,"\Tables\Archive\ServerMSB.sql"
        ,"\Tables\Archive\ServerServers.sql"
        ,"\Tables\Archive\ServerTriggers.sql"

    # ----- views -----
        ,"\Views\dbo\vwProfile.sql"
        ,"\Views\dbo\vwMonitoredServers.sql"
    # -----
        ,"\Views\Reporting\vwErrorLog.sql"

    # ----- stored procedures -----
        ,"\Stored Procedures\dbo\uspGetProfile.sql"
        ,"\Stored Procedures\dbo\uspGetReports.sql"
        ,"\Stored Procedures\dbo\uspGetServers.sql"
        ,"\Stored Procedures\dbo\uspLogError.sql"
        ,"\Stored Procedures\dbo\uspPrintError.sql"
        ,"\Stored Procedures\dbo\usp_CreateDataMaintenanceProcs.sql"
    # -----
        ,"\Stored Procedures\Reporting\uspBlitzResults.sql"
        ,"\Stored Procedures\Reporting\uspBlitzResults4Email.sql"
        ,"\Stored Procedures\Reporting\uspFailedServerAgentJobs.sql"
        ,"\Stored Procedures\Reporting\uspListAvailableServerRoles.sql"
        ,"\Stored Procedures\Reporting\uspListAvailableServers.sql"
        ,"\Stored Procedures\Reporting\uspListDatabaseGrowthTrend.sql"
        ,"\Stored Procedures\Reporting\uspListDatabaseIndexUsage.sql"
        ,"\Stored Procedures\Reporting\uspListDatabaseMissingIndex.sql"
        ,"\Stored Procedures\Reporting\uspListDatabaseTableColumns.sql"
        ,"\Stored Procedures\Reporting\uspListFailedLogins.sql"
        ,"\Stored Procedures\Reporting\uspListServerDrives.sql"
        ,"\Stored Procedures\Reporting\uspListServerFreeSpace.sql"
        ,"\Stored Procedures\Reporting\uspListServerLogins.sql"
        ,"\Stored Procedures\Reporting\uspReportServerInformation.sql"
        ,"\Stored Procedures\Reporting\uspReportSQLBuilds.sql"

    # ----- synonyms -----
        ,"\Synonyms\synonyms.sql"

    # ----- initial data set -----
        ,"\Data\MonitoredServers.sql"
        ,"\Data\Profile.sql"
        ,"\Data\ReportRecipients.sql"
        ,"\Data\Reports.sql"
        ,"\Data\ReportSubscriptions.sql"
        ,"\Data\SystemParams.sql"
    )
}

process {
    # load and run the scripts listed in the array
    "{0} : Starting deployment of {1} database scripts to {2}" -f $(Get-Date -Format "HH:mm:ss"), $filelist.Count, $MonitorSqlInstance
    "{0} : ---------------------------------------------------------------------------" -f $(Get-Date -Format "HH:mm:ss")

    ForEach ($script In $filelist) {
        $scriptname = $script.ToString()
        $scriptexecpath = "$($CurrentPath)$($scriptname)"
        $fileExists = Test-Path $scriptexecpath -PathType Leaf
        if ($fileExists) {
            $sql = Get-Content -Path $scriptexecpath -Raw
            "{0} : Running script: {1}" -f $(Get-Date -Format "HH:mm:ss"), $scriptname
            try { 
                # Windows Authentication
                if ($null -eq $SQLCredential) { Invoke-Sqlcmd -ServerInstance $MonitorSqlInstance -Database $Database -Query $sql }
                # SQL Authentication
                else { Invoke-Sqlcmd -ServerInstance $MonitorSqlInstance -Database $Database -Query $sql -Credential $SQLCredential }
                }
            catch { break } # exit the ForEach on error
        }
    }

    "{0} : ---------------------------------------------------------------------------" -f $(Get-Date -Format "HH:mm:ss")
    "{0} : Script execution complete" -f $(Get-Date -Format "HH:mm:ss")
}

end {
    # deallocate variables
    $Database = $null
    $CurrentPath = $null
    $filelist = $null
    $script = $null
    $scriptname = $null
    $scriptexecpath = $null
    $fileExists = $null
    $sql = $null
}
