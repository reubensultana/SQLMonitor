param(
    [Parameter(Position=1, Mandatory=$true)] [ValidateNotNullOrEmpty()] [string] $RemoteSqlInstance,
    [Parameter(Position=2, Mandatory=$true)] [ValidateNotNull()] [int] $RemoteConnectTimeout = 30,
    [Parameter(Position=3, Mandatory=$false)] [PSCredential] $RemoteSqlAuthCredential,

    [Parameter(Position=4, Mandatory=$true)] [ValidateNotNullOrEmpty()] [string] $MonitorSqlInstance,
    [Parameter(Position=5, Mandatory=$true)] [ValidateNotNull()] [int] $MonitorConnectTimeout = 30,
    [Parameter(Position=6, Mandatory=$false)] [PSCredential] $MonitorSqlAuthCredential,
    [Parameter(Position=7, Mandatory=$true)] [ValidateNotNullOrEmpty()] [string] $MonitorDatabaseName,
    [Parameter(Position=8, Mandatory=$true)] [ValidateNotNullOrEmpty()] [string] $MonitorStagingSchema,

    [Parameter(Position=9, Mandatory=$true)] [ValidateNotNullOrEmpty()] [System.Array] $FileList,
    [Parameter(Position=10, Mandatory=$true)] [ValidateNotNull()] [int] $QueryTimeout = 60,
    [Parameter(Position=11, Mandatory=$true)] [ValidateNotNullOrEmpty()] [string] $LogFilePath
)
<#
# test the Remote Script Block
[string] $RemoteSqlInstance = "localhost,14332"
[int] $RemoteConnectTimeout = 30
[PSCredential] $RemoteSqlAuthCredential = Get-Credential

[string] $MonitorSqlInstance = "localhost,14330"
[int] $MonitorConnectTimeout = 30
[PSCredential] $MonitorSqlAuthCredential = Get-Credential

[string] $MonitorDatabaseName = "SQLMonitor"
[string] $MonitorStagingSchema = "Staging"

[System.Array] $FileList = @(
'.\foo.sql',
'.\man.sql'
'.\choo.sql'
)
[int] $QueryTimeout = 60
[string] $LogFilePath = "C:\Temp\logfile.log"

.\Execute-Remote.ps1 -RemoteSqlInstance $RemoteSqlInstance -RemoteConnectTimeout $RemoteConnectTimeout -RemoteSqlAuthCredential $RemoteSqlAuthCredential `
    -MonitorSqlInstance $MonitorSqlInstance -MonitorConnectTimeout $MonitorConnectTimeout -MonitorSqlAuthCredential $MonitorSqlAuthCredential -MonitorDatabaseName $MonitorDatabaseName `
    -MonitorStagingSchema $MonitorStagingSchema -FileList $FileList -QueryTimeout $QueryTimeout -LogFilePath $LogFilePath -Verbose
#>

# check if dbatools is installed
if ($(Get-InstalledModule -Name dbatools -ErrorAction SilentlyContinue).Name -ne "dbatools") { 
    Write-Error "DBA Tools is not installed. Please install it as explained in the deployment instructions."
    return
}

# import modules - assuming that they must be installed as part of the project prerequisites
if ($(Get-Module -Name dbatools).Name -ne "dbatools") { Import-Module -Name dbatools }

# get script file location
$CurrentPath = [System.IO.Path]::GetDirectoryName($myInvocation.MyCommand.Definition)

# import functions
. "$($CurrentPath)\Write-Log.ps1"

# get the Local Machine name
[string] $HostName = [System.NET.DNS]::GetHostByName($null).HostName
<# 
Alternatives:
    - [System.Net.DNS]::GetHostByName('').HostName
    - $env:COMPUTERNAME
    - [Environment]::MachineName
    - (Get-CimInstance -ClassName Win32_ComputerSystem).Name
#>

$Err = $null
[int] $Success = 0
[string] $ErrorMessage = ""

# check if any files (even though we checked in the parent/calling function)
if ($FileList.Count -gt 0) {
    Write-Log -LogFilePath $LogFilePath -LogEntry "INFO : Processing $RemoteSqlInstance"

    # create the REMOTE connection object - https://docs.dbatools.io/#Connect-DbaInstance
    # use Windows Authentication
    if ($null -eq $RemoteSqlAuthCredential) { $RemoteSqlConnection = Connect-DbaInstance -SqlInstance $RemoteSqlInstance -ConnectTimeout $RemoteConnectTimeout -ClientName $HostName }
    # use SQL Authentication (NOTE: Username and Password sent in clear text - this is by design)
    else { $RemoteSqlConnection = Connect-DbaInstance -SqlInstance $RemoteSqlInstance -ConnectTimeout $RemoteConnectTimeout -ClientName $HostName -SqlCredential $RemoteSqlAuthCredential }

    # create the MONITOR connection object - https://docs.dbatools.io/#Connect-DbaInstance
    # use Windows Authentication
    if ($null -eq $MonitorSqlAuthCredential) { $MonitorSqlConnection = Connect-DbaInstance -SqlInstance $MonitorqlInstance -ConnectTimeout $MonitorConnectTimeout -ClientName $HostName }
    # use SQL Authentication (NOTE: Username and Password sent in clear text - this is by design)
    else { $MonitorSqlConnection = Connect-DbaInstance -SqlInstance $MonitorSqlInstance -ConnectTimeout $MonitorConnectTimeout -ClientName $HostName -SqlCredential $MonitorSqlAuthCredential }
    
    # start file loop
    foreach ($SqlFile in $FileList) {
        try {
            Write-Log -LogFilePath $LogFilePath -LogEntry "INFO : $($SqlFile.Name.ToString()) starting"
            # execute remote query and retrieve results, reusing the current connection object - http://docs.dbatools.io/#Invoke-DbaQuery
            $ResultDataSet = Invoke-DbaQuery -SqlInstance $RemoteSqlConnection -CommandType Text -File $($SqlFile.FullName.ToString()) -QueryTimeout $QueryTimeout -As DataTable -EnableException # -ErrorAction Stop

            $ResultDataSet | Write-DbaDbTableData -SqlInstance $MonitorSqlConnection -Database $MonitorDatabaseName -Table $($SqlFile.BaseName.ToString()) -Schema $MonitorStagingSchema -KeepNulls -EnableException # -ErrorAction Stop
        
            # report success
            $Success = 1
            $ErrorMessage = ""
            Write-Log -LogFilePath $LogFilePath -LogEntry "INFO : $($SqlFile.Name.ToString()) completed successfully"
        }
        catch { 
            # Write-Host "Caught an exception:" -ForegroundColor Red
            # Write-Host "Exception type: $($_.Exception.GetType().FullName)" -ForegroundColor Red
            # Write-Host "Exception message: $($_.Exception.Message)" -ForegroundColor Red
            # Write-Host "Error: " $_.Exception -ForegroundColor Red   
            $Err = $_
            $Success = 0
            $ErrorMessage = $($_.Exception.Message)
            Write-Log -LogFilePath $LogFilePath -LogEntry "ERROR : $($SqlFile.Name.ToString()) failed with error ""$ErrorMessage"""
            # break # On Error Exit the ForEach Loop (?)
            }
        finally { 
            # clean up
        }
    } # end file loop
    Write-Log -LogFilePath $LogFilePath -LogEntry "INFO : Completed $RemoteSqlInstance"
} # end check

# return
return $Err
