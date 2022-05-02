<#
.SYNOPSIS
    SQL Server monitoring tool based on PowerShell v3 and TSQL scripts only

.DESCRIPTION
    SqlMonitor is more of a monitoring solution. This allows DBAs to run preset scripts or TSQL code against a number of SQL Server instances, according to time-based rules defined by what I called "Profiles". The monitoring part allows DBAs to execute the scripts and store the results in a central location for reporting, and trend analysis, etc.

    SqlMonitor also performs data collection of key information from the Instances, hence providing DBAs with a centralised Configuration Management Database (CMDB) of the estate being managed. This, in my opinion, is crucial for the smooth running of an organisation and allows the DBA to answer questions such as:

    * "how many SQL Servers doe we have?"
    * "what licences are in use?"
    * "when was the last time a specific database was backed up?"
    * "is this SQL Server instance running?"
    * "how many logins have not reset their password for more than 90/120/etc. days?"

    Obtaining the information to be able to answer these questions has been a key part of the development of this solution. The standard set of scripts available by default are those which I would have used, on more than one occasion, to help me answer questions from Management, Auditors, a Data Owner, or simply to help me do my job better.

    Since the SqlMonitor is not bound to these scripts, you can write your own code (test it, of course) and add it to the solution. The only other requirement is that you'd have to build
    the table structure/s which will be storing the data being collected. A guide to perform this task is (or will be) included in the final version of the solution.

.PARAMETER MonitorSqlInstance
    The SQL Server instance hosting the SqlMonitor database.

.PARAMETER MonitorDatabaseName
    The name of the SqlMonitor database.

.PARAMETER MonitorConnectTimeout
    Specifies the number of seconds when this cmdlet times out if it cannot successfully connect to an instance of the Database Engine. The timeout value must be an integer value between 
    0 and 65534. If 0 is specified, connection attempts do not time out.

.PARAMETER MonitorProfile
    The name of the Profile to be used. This corresponds to the name of the Schema which owns the tables used to store the data.

.PARAMETER MonitorProfileType
    The Profile Type, used to determine which set of scripts will be run. Allowed values are:
    > Annual
    > Monthly
    > Weekly
    > Daily
    > Hourly
    > Minute
    > Manual
    The value is case-sensitive, because it is used to determine which scripts will be run, and I want to always run.

.PARAMETER QueryTimeout
    Specifies the number of seconds before the queries time out. If a timeout value is not specified, the queries do not time out. The timeout must be an integer value between 1 and 65535.

.PARAMETER Version
    Show the current version number.

.EXAMPLE
    Run the Daily Profile for all Active SQL Server instances
        .\Get-ServerInfo.ps1 
            -MonitorSqlInstance "localhost,14330" `
            -MonitorDatabaseName "SQLMonitor" `
            -MonitorConnectTimeout 30 `
            -MonitorProfile "Monitor" `
            -MonitorProfileType "Daily" `
            -QueryTimeout 360

.EXAMPLE
    Get the codebase version number
        .\Get-ServerInfo.ps1 -Version
        .\Get-ServerInfo.ps1 -v
        .\Get-ServerInfo.ps1 -ver

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
            Mandatory=$true, 
            ParameterSetName = 'Monitor',
            HelpMessage="Enter the SQLMonitor database name.")]
        [ValidateNotNullOrEmpty()]
        [string] $MonitorDatabaseName
    ,
    [Parameter(
            Mandatory=$true, 
            ParameterSetName = 'Monitor',
            HelpMessage="Enter a value between 0 and 65534 for the Connection Timeout.")]
        [ValidateRange(0,65534)]
        [ValidateNotNull()]
        [int] $MonitorConnectTimeout = 30
    ,
    [Parameter(
            Mandatory=$true, 
            ParameterSetName = 'Monitor',
            HelpMessage="Enter the SQLMonitor Profile name.")]
        [ValidateNotNullOrEmpty()]
        [string] $MonitorProfile
    ,
    [Parameter(
            Mandatory=$true, 
            ParameterSetName = 'Monitor',
            HelpMessage="Enter the SQLMonitor Profile Type.")]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("Annual", ”Monthly”, ”Weekly”, "Daily", "Hourly", "Minute", "Manual")]
        [string] $MonitorProfileType
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

function Test-FilePath {
    param(
        [Parameter(Mandatory)] [string] $Path
    )
    if ( $false -eq $(Test-Path -Path $Path -PathType Leaf) ) { 
        Write-Error $("The required file {0} does not exist." -f $FilePath)
        return $false
    }
    return $true
}

# check for existence of external files used by this script
if ($false -eq $(Test-FilePath -Path "$($CurrentPath)\functions\Write-Log.ps1")) { return }
if ($false -eq $(Test-FilePath -Path "$($CurrentPath)\functions\Test-NetworkConnection.ps1")) { return }
if ($false -eq $(Test-FilePath -Path "$($CurrentPath)\functions\Execute-Remote.ps1")) { return }

# import functions
. "$($CurrentPath)\functions\Write-Log.ps1"
. "$($CurrentPath)\functions\Test-NetworkConnection.ps1"

# --------------------------------------------------------------------------------
function Get-ServerInfo() {
    [CmdletBinding()]  
    param(  
        [Parameter(Position=1, Mandatory=$true)] [ValidateNotNullOrEmpty()] [string] $MonitorSqlInstance,
        [Parameter(Position=2, Mandatory=$true)] [ValidateNotNullOrEmpty()] [string] $MonitorDatabaseName,
        [Parameter(Position=3, Mandatory=$true)] [ValidateNotNull()] [int] $MonitorConnectTimeout,
        [Parameter(Position=4, Mandatory=$true)] [ValidateNotNullOrEmpty()] [string] $MonitorProfile,
        [Parameter(Position=5, Mandatory=$true)] [ValidateNotNullOrEmpty()] [string] $MonitorProfileType,
        [Parameter(Position=6, Mandatory=$true)] [ValidateNotNull()] [int] $QueryTimeout
    )

    # --------------------------------------------------------------------------------
    # generic variables
    [string] $ApplicationName = "SqlMonitor"
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
    [string] $LogFolder = "{0}\LOG" -f $(Get-Location).Path
    [string] $LogFileName = "{0}_{1}" -f $ApplicationName, $(Get-Date -Format 'yyyyMMddHHmmssfff')
    [string] $LogFilePath = "{0}\{1}.log" -f $LogFolder, $LogFileName
    # check and create logging subfolder/s
    if ($false -eq $(Test-Path -Path $LogFolder -PathType Container -ErrorAction SilentlyContinue)) {
        $null = New-Item -Path $LogFolder -ItemType Directory -Force -ErrorAction SilentlyContinue
    }

    # --------------------------------------------------------------------------------
    #region set variables
    [string] $ScriptRoot = "{0}\scripts\" -f $CurrentPath
    [bool] $IsAlive = $false
    [string] $SqlCmd = ""
    #endregion

    # region functional variables
    $AvailableInstancesDataSet = New-Object System.Collections.ArrayList
    [string] $ServerName = ""
    [int] $TcpPort = 0
    [string] $InstanceName = ""
    [string] $ScriptPath = ""
    [PSCredential] $SqlAuthCredential = $null
    #endregion
    
    # --------------------------------------------------------------------------------
    # start here
    Write-Log -LogFilePath $LogFilePath -LogEntry "=============================="
    Write-Log -LogFilePath $LogFilePath -LogEntry "Starting function: Get-ServerInfo"
    Write-Log -LogFilePath $LogFilePath -LogEntry "Server Name:       " -f $MonitorSqlInstance
    Write-Log -LogFilePath $LogFilePath -LogEntry "Database Name:     " -f $MonitorDatabaseName
    Write-Log -LogFilePath $LogFilePath -LogEntry "Connect Timeout:   " -f $MonitorConnectTimeout
    Write-Log -LogFilePath $LogFilePath -LogEntry "Profile Name:      " -f $MonitorProfile
    Write-Log -LogFilePath $LogFilePath -LogEntry "Profile Type:      " -f $MonitorProfileType
    Write-Log -LogFilePath $LogFilePath -LogEntry "Query Timeout:     " -f $QueryTimeout
    Write-Log -LogFilePath $LogFilePath -LogEntry "=============================="
    Write-Log -LogFilePath $LogFilePath -LogEntry ""
    Write-Log -LogFilePath $LogFilePath -LogEntry ""

    # --------------------------------------------------------------------------------
    # create the MONITOR connection object - https://docs.dbatools.io/Connect-DbaInstance
        # https://docs.microsoft.com/en-us/dotnet/api/microsoft.data.sqlclient.sqlconnection
    $MonitorSqlConnection = New-Object Microsoft.SqlServer.Management.Smo.Server
    # $MonitorSqlConnection = New-Object Microsoft.Data.SqlClient.SQLConnection
    # use Windows Authentication
    if ($null -eq $MonitorSqlAuthCredential) { $MonitorSqlConnection = Connect-DbaInstance -SqlInstance $MonitorqlInstance -Database $MonitorDatabaseName -ConnectTimeout $MonitorConnectTimeout -ClientName $HostName }
    # use SQL Authentication (NOTE: Username and Password sent in clear text - this is by design)
    else { $MonitorSqlConnection = Connect-DbaInstance -SqlInstance $MonitorSqlInstance -Database $MonitorDatabaseName -ConnectTimeout $MonitorConnectTimeout -ClientName $HostName -SqlCredential $MonitorSqlAuthCredential }
    # TODO: Disconnect-DbaInstance

    # --------------------------------------------------------------------------------
    # get profile (incl, script names and scripts) from MONITOR database - http://docs.dbatools.io/Invoke-DbaQuery
    $SqlCmd = "dbo.uspGetProfile"
    # define the SQL command input parameters
    $QueryParameters = @{
        "ProfileName" = $MonitorProfile;
        "ProfileType" = $MonitorProfileType;
    };
    # https://docs.microsoft.com/en-us/dotnet/api/system.data.datatable
    $ScriptsDataSet = New-Object System.Data.DataTable
    $ScriptsDataSet = Invoke-DbaQuery -SqlInstance $MonitorSqlConnection -Database $MonitorDatabaseName -CommandType StoredProcedure -Query $SqlCmd -SqlParameters $QueryParameters -QueryTimeout $QueryTimeout -As DataTable -EnableException -ErrorAction Stop
    if ($ScriptsDataSet.Rows.Count -eq 0) {
        Write-Log -LogFilePath $LogFilePath -LogEntry $("No scripts found for profile {0} and type {1}." -f $MonitorProfile, $MonitorProfileType)
        return
    }

    # verify that the scripts dataset is valid - we're going to pass this to the Runspace code
    # doing this here to avoid overheads related to reading TSQL content from file for every SQL Server instance
    # also prevents possible file locking issuesand delays due to concurrent file access
    foreach ($Script in $ScriptsDataSet) {
        $ScriptPath = $ScriptRoot + $Script.ScriptName + ".sql"
        $ScriptName = $Script.ScriptName
        # the script that should be executed, retrieved from the database
        $ExecuteScript = $Script.ExecuteScript
        # if the script is not stored in the database, load it from the file
        if ([string]::IsNullOrEmpty($ExecuteScript)) {
            # check that the script file exists
            if (Test-Path $ScriptPath -PathType Leaf) {
                # read the TSQL code from the file 
                $ExecuteScript = Get-Content -Path $ScriptPath -Raw
                # update the original value in memory with the file contents
                $Script.ExecuteScript = $ExecuteScript
            }
            else {
                # logging only; further checks below
                Write-Log -LogFilePath $LogFilePath -LogEntry $("The script file {0} does not exist." -f $ScriptName)
                $Script.ExecuteScript = ""          # avoids checking for $null below
            }
        }
        # if at this stage the $ExecuteScript variable is still empty, then exit the loop and stop the process
        if ([string]::IsNullOrEmpty($ExecuteScript)) { 
            Write-Log -LogFilePath $LogFilePath -LogEntry $("The code for the {0} script could not be located." -f $Script.ScriptName)
            $Script.ExecuteScript = ""          # avoids checking for $null below
        }
    }
    # check again...
    if ( $($ScriptsDataSet | Where-Object -Property ExecuteScript -ne -Value "").Count -eq 0 ) {
        Write-Log -LogFilePath $LogFilePath -LogEntry "No valid TSQL scripts were provided."
        return
    }
    
    # --------------------------------------------------------------------------------
    # get list of active servers from MONITOR database - http://docs.dbatools.io/Invoke-DbaQuery
    $SqlCmd = "dbo.uspGetServers"
    # https://docs.microsoft.com/en-us/dotnet/api/system.data.datatable
    $InstancesDataSet = New-Object System.Data.DataTable
    $InstancesDataSet = Invoke-DbaQuery -SqlInstance $MonitorSqlConnection -CommandType StoredProcedure -Query $SqlCmd -QueryTimeout $QueryTimeout -As DataTable -EnableException -ErrorAction Stop
    if ($InstancesDataSet.Rows.Count -eq 0) {
        Write-Log -LogFilePath $LogFilePath -LogEntry "No active servers found in SQL Monitor database."
        return
    }

    # verify connectivity to each server
    Write-Log -LogFilePath $LogFilePath -LogEntry "Verifying connectivity to the list of SQL Server instances - this might take a while..."
    foreach ($Instance in $InstancesDataSet) {
        # extract parts
        $ServerName = $Instance.ServerName
        $ServerAlias = $Instance.ServerAlias
        $ServerIpAddress = $Instance.ServerIpAddress
        $TcpPort = $Instance.SqlTcpPort
        # check the TcpPort
        if ($TcpPort -gt 0) {
            $InstanceName = "{0},{1}" -f $ServerName, $TcpPort
            # one more check to remove the instance name...
            if ($true -eq $ServerName.Contains("\")) {$ServerName = $ServerName.Split("\")[0]}
            # check TCP connection on the specified port and stop execution on failure
            $IsAlive = Test-Port -HostName $ServerName -Port $TcpPort
            # test using ServerAlias and update the ServerName property if the test was successful
            if ($false -eq $IsAlive) { $IsAlive = Test-Port -HostName $ServerAlias -Port $TcpPort } else { $Instance.ServerName = $ServerAlias }
            # test using ServerIpAddress and update the ServerName property if the test was successful
            if ($false -eq $IsAlive) { $IsAlive = Test-Port -HostName $ServerIpAddress -Port $TcpPort } else { $Instance.ServerName = $ServerIpAddress }
            # add to the array
            if ($true -eq $IsAlive) {
                $Instance.isAlive = 1
                #$AvailableInstancesDataSet.Add($Server.ToString()) > $null # suppress output
                #Write-Log -LogFilePath $LogFilePath -LogEntry $("Adding {0} to the actual list." -f $InstanceName)
            }
            else { 
                Write-Log -LogFilePath $LogFilePath -LogEntry $("Instance {0} could not be reached." -f $InstanceName)
            }
        }
        else {
            Write-Log -LogFilePath $LogFilePath -LogEntry $("The server {0} does not have a valid TCP Port number." -f $ServerName)
        }
    }
    $AvailableInstancesDataSet = $InstancesDataSet | Where-Object -Property isAlive -eq 1 | Select-Object -Property ServerName, SqlTcpPort, SqlLogin, SqlLoginSecret
    # check again...
    if ($AvailableInstancesDataSet.Count -eq 0) {
        Write-Log -LogFilePath $LogFilePath -LogEntry "No valid SQL Server instances were provided."
        return
    }

    # --------------------------------------------------------------------------------
    #region remote script - this is the workhorse
    $RemoteScriptBlock = { Get-Content "$($CurrentPath)\functions\Execute-Remote.ps1" -Raw }
    #endregion

    #region set up Runspace Pool
    [int] $MaxRunningJobs = $($env:NUMBER_OF_PROCESSORS + 1) # number of Logical CPUs
    $DefaultRunspace = [System.Management.Automation.Runspaces.Runspace]::DefaultRunspace
    $RunspacePool = [RunspaceFactory]::CreateRunspacePool(1,$MaxRunningJobs)
    $RunspacePool.ApartmentState = "MTA" # avalable values: MTA (multithreaded), STA (single-threaded) 
    $RunspacePool.Open()
    $Runspaces = @()
    #endregion

    #region execute script on remote servers
    $timer = [System.Diagnostics.Stopwatch]::StartNew()

    # start jobs on all servers
    if ( ( $($ScriptsDataSet | Where-Object -Property ExecuteScript -ne -Value "").Count -gt 0 ) -and ($AvailableInstancesDataSet.Count -gt 0) ) {
        foreach ($InstanceName in $AvailableInstancesDataSet) {
            $ServerName = $("{0},{1}" -f $InstanceName.ServerName, $InstanceName.SqlTcpPort)
            [String] $SqlLogin = $InstanceName.SqlLogin
            [SecureString] $SqlLoginSecret = ConvertTo-SecureString $($InstanceName.SqlLoginSecret) -AsPlainText -Force
            $SqlAuthCredential = New-Object System.Management.Automation.PSCredential ($SqlLogin, $SqlLoginSecret)

            Write-Log -LogFilePath $LogFilePath -LogEntry $("Processing instance: {0}" -f $ServerName)

            # Runspace code starts here
            # $RemoteScriptBlock input parameters
            <#
            0. $MonitorSqlConnection = $MonitorSqlConnection
            1. $MonitorDatabaseName = $MonitorDatabaseName
            2. $MonitorProfile
            3. $InstanceName
            4. $InstanceCredentials
            5. $ScriptsDataSet
            6. $LogFilePath
            #>


            $ConcurrentQueue = New-Object System.Collections.Concurrent.ConcurrentQueue[string]
            $Runspace = [PowerShell]::Create()
            # add remote script code
            $null = $Runspace.AddScript($RemoteScriptBlock)
            # add parameters, in the order they are defined in the script
            $null = $Runspace.AddArgument($MonitorSqlConnection)
            $null = $Runspace.AddArgument($MonitorDatabaseName)
            $null = $Runspace.AddArgument($MonitorProfile)
            $null = $Runspace.AddArgument($ServerName)
            $null = $Runspace.AddArgument($SqlAuthCredential)       # <== currently NULL; on the TODO list
            $null = $Runspace.AddArgument($ScriptsDataSet)
            $null = $Runspace.AddArgument($LogFilePath)
            $Runspace.RunspacePool = $RunspacePool
            $Runspaces += [PSCustomObject]@{ Pipe = $Runspace; Status = $Runspace.BeginInvoke() }
            
            # While streaming ...
            while ($Runspaces.Status.IsCompleted -notcontains $true) {
                $item = $null
                if ($ConcurrentQueue.TryDequeue([ref]$item)) { "$item" }
            }
            # Drain the stream as the Runspace is closed, just to be safe
            if ($ConcurrentQueue.IsEmpty -ne $true) {
                $item = $null
                while ($ConcurrentQueue.TryDequeue([ref]$item)) { "$item" }
            }
            foreach ($Runspace in $Runspaces) {
                [void]$Runspace.Pipe.EndInvoke($Runspace.Status) # EndInvoke method retrieves the results of the asynchronous calls
                $Runspace.Pipe.Dispose()
            }
        }
    }

    [int] $secs = $timer.Elapsed.TotalSeconds
    Write-Log -LogFilePath $LogFilePath -LogEntry "----------"
    Write-Log -LogFilePath $LogFilePath -LogEntry "Servers processed: $($AvailableInstancesDataSet.Count)"
    Write-Log -LogFilePath $LogFilePath -LogEntry $("Duration: {0} seconds" -f $secs)

    $RunspacePool.Close()
    $RunspacePool.Dispose()

    # clean up SQL connections and reset Default Runspace
    [System.Data.SQLClient.SqlConnection]::ClearAllPools()
    [System.Management.Automation.Runspaces.Runspace]::DefaultRunspace = $DefaultRunspace
    #endregion

    #region clean up

    #endregion
    Write-Log -LogFilePath $LogFilePath -LogEntry "Collection completed."
}

# run this only if the parameters have been passed to the script
# interface implemented to be called from Windows Task Scheduler or similar applications
if (($ServerInstance -ne '') -and ($Database -ne '') -and ($ProfileName -ne '') -and ($ProfileType -ne '')) {
    Get-ServerInfo -ServerInstance $ServerInstance -Database $Database -ProfileName $ProfileName -ProfileType $ProfileType -QueryTimeout $QueryTimeout
}
# otherwise, do nothing
