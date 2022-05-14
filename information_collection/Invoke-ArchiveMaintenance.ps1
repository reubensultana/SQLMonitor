<#
.SYNOPSIS
    Data Archiving function for the SQL Server monitoring tool based on PowerShell v3 and TSQL scripts only

.DESCRIPTION
    This function is used to archive data from the SQL Server monitoring tool.

.PARAMETER MonitorSqlInstance
    The SQL Server instance hosting the SqlMonitor database.

.PARAMETER MonitorSqlAuthCredential
    The SQL Login credential object used to connect to the SqlMonitor database.

.PARAMETER MonitorDatabaseName
    The name of the SqlMonitor database.

.PARAMETER QueryTimeout
    Specifies the number of seconds before the queries time out. If a timeout value is not specified, the queries do not time out. The timeout must be an integer value between 1 and 65535.

.PARAMETER Version
    Show the current version number.

.EXAMPLE
    Run the Data Archiving process, using Windows Authentication to connect to the Monitor repository.
        .\Invoke-ArchiveMaintenance.ps1 `
            -MonitorSqlInstance "localhost,14330" `
            -MonitorDatabaseName "SQLMonitor" `
            -QueryTimeout 360

.EXAMPLE
    Run the Data Archiving process, using SQL Authentication to connect to the Monitor repository.
        $MonitorSqlAuthCredential = Get-Credential -UserName "sa"
    
        .\Invoke-ArchiveMaintenance.ps1 `
            -MonitorSqlInstance "localhost,14330" `
            -MonitorSqlAuthCredential $MonitorSqlAuthCredential `
            -MonitorDatabaseName "SQLMonitor" `
            -QueryTimeout 360

.EXAMPLE
    Get the codebase version number
        .\Invoke-ArchiveMaintenance.ps1 -Version
        .\Invoke-ArchiveMaintenance.ps1 -v
        .\Invoke-ArchiveMaintenance.ps1 -ver

.NOTES
    Author: Reuben Sultana (@ReubenSultana), sqlserverdiaries.com
    Website: https://sqlserverdiaries.com
    Copyright: (c) 2022 by Reuben Sultana, licensed under MIT
    License: MIT https://opensource.org/licenses/MIT

.LINK
    https://github.com/reubensultana/SQLMonitor
#>
[CmdletBinding(DefaultParameterSetName = 'Monitor')]
param(
    [Parameter(
            Mandatory=$true, 
            ParameterSetName = 'Monitor',
            HelpMessage="Enter the SQLMonitor repository Instance name.")]
        [ValidateNotNullOrEmpty()]
        [string] $MonitorSqlInstance
    ,
    [Parameter(
        Mandatory=$false,
        ParameterSetName = 'Monitor',
        HelpMessage="Enter the SQL Login credential objects used to connect to the SqlMonitor repository.")]
    [PSCredential] $MonitorSqlAuthCredential
    ,
    [Parameter(
            Mandatory=$true, 
            ParameterSetName = 'Monitor',
            HelpMessage="Enter the SQLMonitor database name.")]
        [ValidateNotNullOrEmpty()]
        [string] $MonitorDatabaseName
    ,
    [Parameter(
            Mandatory=$true, 
            ParameterSetName = 'Monitor',
            HelpMessage="Enter a value between 1 and 65535 for the Query Timeout.")]
        [ValidateRange(1,65535)]
        [ValidateNotNull()]
        [int] $QueryTimeout = 360
    ,
    [Parameter(
            Mandatory=$false, 
            ParameterSetName = 'Version')]
        [Alias("v","ver")]
        [switch] $Version
)
# get script file location
$RootPath = [System.IO.Path]::GetDirectoryName($myInvocation.MyCommand.Definition)
[string] $TestFilePathScript = "$($RootPath)\functions\Test-FilePath.ps1"
. $TestFilePathScript

# get information from the config file
[string] $SettingsFile = "$($RootPath)\Settings.xml"
if ($true -eq $(Test-FilePath($SettingsFile))) {
    [xml]$ConfigFile = Get-Content $SettingsFile

    [string] $ApplicationName = $ConfigFile.Settings.System.ApplicationName
    [string] $Author = $ConfigFile.Settings.System.Author
    [string] $VersionBuild = $ConfigFile.Settings.System.VersionBuild
    [string] $ReleaseDate = $ConfigFile.Settings.System.ReleaseDate
}
if ($true -eq $Version) {
    Write-Output $("{0} Version {1}}" -f $ApplicationName, $VersionBuild)
    Write-Output $("© {0} - {1}" -f $Author, $ReleaseDate)
    return
}

# check if dbatools is installed
if ($(Get-InstalledModule -Name dbatools -ErrorAction SilentlyContinue).Name -ne "dbatools") { 
    Write-Error "DBA Tools is not installed. Please install it as explained in the deployment instructions."
    return
}

# import modules - assuming that they must be installed as part of the project prerequisites
if ($(Get-Module -Name dbatools).Name -ne "dbatools") { Import-Module -Name dbatools }

[string] $LoggingFunctionScript = "$($RootPath)\functions\Write-Log.ps1"

# check for existence of external files used by this script
if ($false -eq $(Test-FilePath -FilePath $LoggingFunctionScript)) { return }

# import function/s
. $LoggingFunctionScript

# --------------------------------------------------------------------------------

function Invoke-ArchiveMaintenance () {
    [CmdletBinding()]  
    param(  
    [Parameter(Position=0, Mandatory=$true)] [string]$ServerInstance, 
    [Parameter(Position=1, Mandatory=$true)] [string]$Database,
	[Parameter(Position=2, Mandatory=$false)] [string]$QueryTimeout = 360
    )  
    
    # generic variables

    # get the Local Machine name
    [string] $HostName = [System.NET.DNS]::GetHostByName($null).HostName
    <# 
    Alternatives:
        - [System.Net.DNS]::GetHostByName('').HostName
        - $env:COMPUTERNAME
        - [Environment]::MachineName
        - (Get-CimInstance -ClassName Win32_ComputerSystem).Name
    #>
    
    # --------------------------------------------------------------------------------
    # variables used for logging
    [string] $LogFolder = "{0}\LOG" -f $RootPath
    [string] $LogFileName = "{0}_{1}" -f $ApplicationName, $(Get-Date -Format 'yyyyMMddHHmmssfff')
    [string] $LogFilePath = "{0}\{1}.log" -f $LogFolder, $LogFileName
    # check and create logging subfolder/s
    if ($false -eq $(Test-Path -Path $LogFolder -PathType Container -ErrorAction SilentlyContinue)) {
        $null = New-Item -Path $LogFolder -ItemType Directory -Force -ErrorAction SilentlyContinue
    }

    #region set variables
    [string] $SqlCmd = ""
    #endregion

    # --------------------------------------------------------------------------------    
    # start here
    Write-Log -LogFilePath $LogFilePath -LogEntry "=============================="
    Write-Log -LogFilePath $LogFilePath -LogEntry "Starting function: Invoke-ArchiveMaintenance"
    Write-Log -LogFilePath $LogFilePath -LogEntry $("Server Name:       {0}" -f $MonitorSqlInstance)
    Write-Log -LogFilePath $LogFilePath -LogEntry $("Database Name:     {0}" -f $MonitorDatabaseName)
    Write-Log -LogFilePath $LogFilePath -LogEntry $("Query Timeout:     {0}" -f $QueryTimeout)
    Write-Log -LogFilePath $LogFilePath -LogEntry "=============================="
    Write-Log -LogFilePath $LogFilePath -LogEntry " "
    Write-Log -LogFilePath $LogFilePath -LogEntry " "

    # --------------------------------------------------------------------------------
    # create the MONITOR connection object - https://docs.dbatools.io/Connect-DbaInstance
    # https://docs.microsoft.com/en-us/dotnet/api/microsoft.data.sqlclient.sqlconnection
    $MonitorSqlConnection = New-Object Microsoft.SqlServer.Management.Smo.Server
    # $MonitorSqlConnection = New-Object Microsoft.Data.SqlClient.SQLConnection
    # use Windows Authentication
    if ($null -eq $MonitorSqlAuthCredential) { 
        Write-Log -LogFilePath $LogFilePath -LogEntry "Using Windows Authentication"
        $MonitorSqlConnection = Connect-DbaInstance -SqlInstance $MonitorSqlInstance -Database $MonitorDatabaseName -ConnectTimeout $MonitorConnectTimeout -ClientName $HostName }
    # use SQL Authentication (NOTE: Username and Password sent in clear text - this is by design)
    else { 
        Write-Log -LogFilePath $LogFilePath -LogEntry "Using SQL Authentication"
        $MonitorSqlConnection = Connect-DbaInstance -SqlInstance $MonitorSqlInstance -Database $MonitorDatabaseName -ConnectTimeout $MonitorConnectTimeout -ClientName $HostName -SqlCredential $MonitorSqlAuthCredential }
    # TODO: Disconnect-DbaInstance

    # --------------------------------------------------------------------------------
    # execute the Archiving stored procedure in the MONITOR database - http://docs.dbatools.io/Invoke-DbaQuery
    Write-Log -LogFilePath $LogFilePath -LogEntry "Getting Profile details"
    $SqlCmd = "Archive.usp_Mantain_Archive"
    Invoke-DbaQuery -SqlInstance $MonitorSqlConnection -Database $MonitorDatabaseName -CommandType StoredProcedure -Query $SqlCmd -QueryTimeout $QueryTimeout -As DataTable -EnableException -ErrorAction Stop

    #region clean up
    # Close and dispose of the connection object - http://docs.dbatools.io/Disconnect-DbaInstance
    Disconnect-DbaInstance -SqlInstance $MonitorSqlConnection

    #endregion
    Write-Log -LogFilePath $LogFilePath -LogEntry "Archiving complete."
}

# run this only if the parameters have been passed to the script
# interface implemented to be called from Windows Task Scheduler or similar applications
if ($null -eq $MonitorSqlAuthCredential) { 
    Invoke-ArchiveMaintenance `
        -MonitorSqlInstance $MonitorSqlInstance `
        -MonitorDatabaseName $MonitorDatabaseName `
        -QueryTimeout $QueryTimeout
}
# use SQL Authentication (NOTE: Username and Password sent in clear text - this is by design)
else { 
    Invoke-ArchiveMaintenance `
        -MonitorSqlInstance $MonitorSqlInstance `
        -MonitorSqlAuthCredential $MonitorSqlAuthCredential `
        -MonitorDatabaseName $MonitorDatabaseName `
        -QueryTimeout $QueryTimeout
}
