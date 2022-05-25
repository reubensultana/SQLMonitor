<#
.SYNOPSIS
    Executes a list of SQL script files agianst a list of SQL Server instances.

.DESCRIPTION
    Based on an open-source project hosted at https://github.com/reubensultana/Scripts-Deployment  
    Reads a text file containing a list of Servers, another file containing a list of TSQL Scripts, and executes all of the scripts against the list of remote servers.
    The output is stored as text in a LOG file in a subfolder, using the time stamp name for the file name.

.PARAMETER ServerListFile
    A text file containing the list of servers where the scripts will be executed/deployed.
    NOTE: the files must exist (DOH!) and have to have a SQL extension.

.PARAMETER ScriptListFile
    A text file containing the paths to the list of files that will be executed/deployed.
    NOTE: each script must contain the name of the affected database, otherwise execution will default to "master".

.PARAMETER ConnectionTimeout
    Specifies the number of seconds when this cmdlet times out if it cannot successfully connect to an instance of the Database Engine. The timeout value must be an integer value between 0 and 65534. If 0 is specified, connection attempts do not time out.

.PARAMETER QueryTimeout
    Specifies the number of seconds before the queries time out. If a timeout value is not specified, the queries do not time out. The timeout must be an integer value between 1 and 65535.

.Example
    Parameters inline: 
    .\Deploy-Scripts.ps1 -ServerListFile .\ServerList.txt -ScriptListFile .\FileList.txt -ConnectionTimeout 60 -QueryTimeout 60

.Example
    This will use defaults for ConnectionTimeout and QueryTimeout: 
    .\Deploy-Scripts.ps1 -ServerListFile .\ServerList.txt -ScriptListFile .\FileList.txt

.Example
    Parameter values in variables: 
    [string] $ServerListFile = ".\ServerList.txt"
    [string] $ScriptListFile = ".\FileList.txt"
    .\Deploy-Scripts.ps1 -ServerListFile .\ServerList.txt -ScriptListFile .\FileList.txt -ConnectionTimeout 60 -QueryTimeout 60

.Example
    This is my favourite example. Passing parameter values using Splatting:
    $Params = @{
        ServerListFile      = ".\ServerList.txt"
        ScriptListFile      = ".\FileList.txt"
        ConnectionTimeout   = 60
        QueryTimeout        = 60
        Verbose             = $true
    }
    .\Deploy-Scripts.ps1 @Params 

#>
# get generic params/configuration
[CmdletBinding(DefaultParameterSetName = 'RemoteExecute')]
param(
    [Parameter(
            Mandatory=$true, 
            ParameterSetName = 'RemoteExecute',
            HelpMessage="Enter the path to the file containing the list of SQL Server instances.")]
        [ValidateNotNull()]
        [IO.FileInfo] $ServerListFile
    ,
    [Parameter(
            Mandatory=$true, 
            ParameterSetName = 'RemoteExecute',
            HelpMessage="Enter the path to the file containing the list of Scripts.")]
        [ValidateNotNull()]
        [IO.FileInfo] $ScriptListFile
    ,
    [Parameter(
            Mandatory=$false, 
            ParameterSetName = 'RemoteExecute',
            HelpMessage="Enter a value between 0 and 65534 for the Connection Timeout.")]
        [ValidateRange(0,65534)]
        [ValidateNotNull()]
        [int] $ConnectionTimeout = 60
    ,
    [Parameter(
            Mandatory=$false, 
            ParameterSetName = 'RemoteExecute',
            HelpMessage="Enter a value between 1 and 65535 for the Query Timeout.")]
        [ValidateRange(1,65535)]
        [ValidateNotNull()]
        [int] $QueryTimeout = 360
    ,
    [Parameter(
            Mandatory=$false, 
            ParameterSetName = 'RemoteExecute',
            HelpMessage="Choose whether to export the results to an Excel (XLS) file.")]
        [bool] $ExportToExcel = $true
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

# check if ImportExcel is installed
if ($(Get-InstalledModule -Name ImportExcel -ErrorAction SilentlyContinue).Name -ne "ImportExcel") { 
    Write-Error "ImportExcel is not installed. Please install it as explained in the deployment instructions."
    return
}
# import modules - assuming that they must be installed as part of the project prerequisites
if ($(Get-Module -Name ImportExcel).Name -ne "ImportExcel") { Import-Module -Name ImportExcel }

[string] $LoggingFunctionScript = "$($RootPath)\functions\Write-Log.ps1"
[string] $TestNetConnFunctionScript = "$($RootPath)\functions\Test-NetworkConnection.ps1"

# check for existence of external files used by this script
if ($false -eq $(Test-FilePath -FilePath $LoggingFunctionScript)) { return }
if ($false -eq $(Test-FilePath -FilePath $TestNetConnFunctionScript)) { return }

# import function/s
. $LoggingFunctionScript
. $TestNetConnFunctionScript

# --------------------------------------------------------------------------------
#region set default values if missing
if ($null -eq $ServerListFile)      {$ServerListFile = "$($RootPath)\ServerList.txt"}
if ($null -eq $ScriptListFile)      {$ScriptListFile = "$($RootPath)\FileList.txt"}
if ($null -eq $ConnectionTimeout)   {$ConnectionTimeout = 60}
if ($null -eq $QueryTimeout)        {$QueryTimeout = 360}
#endregion

# --------------------------------------------------------------------------------
#region set variable
[string] $ConnectionStringTemplate = "Server={0};Database={1};Integrated Security={2};Application Name={3};Connection Timeout={4};"
[string] $RemoteServerConnection = ""
[string] $ServerName = ""
[int] $TcpPort = ""
[bool] $IsAlive = $false
$ActualServerList = New-Object System.Collections.ArrayList
# $ActualFileList = New-Object System.Collections.ArrayList

# --------------------------------------------------------------------------------
# variables used for logging
[string] $LogFolder = "{0}\LOG" -f $RootPath
[string] $LogFileName = "{0}_{1}" -f $ApplicationName, $(Get-Date -Format 'yyyyMMddHHmmssfff')
[string] $LogFilePath = "{0}\{1}.log" -f $LogFolder, $LogFileName
# check and create logging subfolder/s
if ($false -eq $(Test-Path -Path $LogFolder -PathType Container -ErrorAction SilentlyContinue)) {
    $null = New-Item -Path $LogFolder -ItemType Directory -Force -ErrorAction SilentlyContinue
}

# --------------------------------------------------------------------------------
#region get list of remote servers and files to execute
# check Server List
if ($false -eq (Test-Path $ServerListFile -PathType Leaf)) {
    Write-Log -LogFilePath $LogFilePath -LogEntry "The Server List file could not be found."
    return
}
else { $InstancesList = Get-Content -Path $ServerListFile }
# check File List
if ($false -eq (Test-Path $ScriptListFile -PathType Leaf)) {
    Write-Log -LogFilePath $LogFilePath -LogEntry "The File List file could not be found."
    return
}
else { $ScriptListFiles = Get-Content -Path $ScriptListFile }
# apply more checks and build the list of actual Servers and SQL files
# check if any
if ($InstancesList.Count -eq 0) {
    Write-Log -LogFilePath $LogFilePath -LogEntry "No servers were provided." 
    return
}
# verify connectivity to each server
Write-Log -LogFilePath $LogFilePath -LogEntry "Verifying connectivity to the list of servers - this might take a while..."
foreach ($Instance in $InstancesList) {
    # extract parts
    $ServerName = $Instance.Split(",")[0]
    $TcpPort = $Instance.Split(",")[1]
    # check the TcpPort
    if ($TcpPort -gt 0) {
        $InstanceName = "{0},{1}" -f $ServerName, $TcpPort
        # one more check to remove instance name...
        if ($true -eq $ServerName.Contains("\")) {$ServerName = $ServerName.Split("\")[0]}
        # check TCP connection on the specified port and stop execution on failure
        $IsAlive = Test-Port -HostName $ServerName -Port $TcpPort
        # add to the array
        if ($true -eq $IsAlive) { 
            $ActualServerList.Add($Instance.ToString()) > $null # suppress output
            Write-Log -LogFilePath $LogFilePath -LogEntry $("Adding {0} to the actual list." -f $InstanceName)
        }
        else { 
            Write-Log -LogFilePath $LogFilePath -LogEntry $("Instance {0} could not be reached." -f $InstanceName)
        }
    }
    else {
        Write-Log -LogFilePath $LogFilePath -LogEntry $("The server {0} does not have a valid TCP Port number." -f $ServerName)
    }
}
# check again...
if ($ActualServerList.Count -eq 0) {
    Write-Log -LogFilePath $LogFilePath -LogEntry "No valid SQL Server instances were provided."
    return
}

# check if any
if ($ScriptListFiles.Count -eq 0) {
    Write-Log -LogFilePath $LogFilePath -LogEntry "No script files were provided." 
    return
}
# verify existence of each file, the use each one to build the scripts dataset - we're going to pass this to the Runspace code
# doing this here to avoid overheads related to reading TSQL content from file for every SQL Server instance
# also prevents possible file locking issuesand delays due to concurrent file access
Write-Log -LogFilePath $LogFilePath -LogEntry "Verifying the list of script files"

# build a DataTable structure
$ScriptsDataSet = New-Object System.Data.DataTable
$ScriptsDataSet.Columns.Add("ScriptName", "System.String")
$ScriptsDataSet.Columns.Add("ExecuteScript", "System.String")

# --------------------------------------------------------------------------------
foreach ($ScriptFile in $ScriptListFiles) {
    if ($true -eq $(Test-Path $ScriptFile -PathType Leaf)) {
        # convert the string to a System.IO.FileSystemInfo type
        $ScriptFile = Get-Item -Path $ScriptFile
        # only SQL files allowed; and check if file exists
        if ($ScriptFile.Extension -like ".sql") {
            # read the TSQL code from the file 
            $ExecuteScript = Get-Content -Path $($ScriptFile.FullName) -Raw
            # if at this stage the $ExecuteScript variable is empty, then do not add it to the dataset
            if ([string]::IsNullOrEmpty($ExecuteScript)) { 
                Write-Log -LogFilePath $LogFilePath -LogEntry $("The code for the {0} script could not be located." -f $($ScriptFile.Name))
            }
            else {
                # add to the DataTable
                $ScriptRow = $ScriptsDataSet.NewRow()
                $ScriptRow.ScriptName = $ScriptFile.Name
                $ScriptRow.ExecuteScript = $ExecuteScript
                $ScriptsDataSet.Rows.Add($ScriptRow)

                Write-Log -LogFilePath $LogFilePath -LogEntry $("The script file {0} has been added." -f $($ScriptFile.Name))
            }
        }
        else {
            Write-Log -LogFilePath $LogFilePath -LogEntry $("The script file {0} is not valid." -f $($ScriptFile.Name))
        }
    }
    else { 
        Write-Log -LogFilePath $LogFilePath -LogEntry $("The script file {0} does not exist." -f $($ScriptFile.Name))
    }
}
# check again...
if ( $($ScriptsDataSet | Where-Object -Property ExecuteScript -ne -Value "").Count -eq 0 ) {
    Write-Log -LogFilePath $LogFilePath -LogEntry "No valid TSQL scripts could be located."
    return
}
#endregion
<# -------------------------------------------------- #>
# if all good, then continue...


#region remote script - this is the workhorse
$RemoteScriptBlock = { 
    [CmdletBinding(DefaultParameterSetName = 'RemoteExecute')]
    param(
        [Parameter(
            Mandatory=$true,
            ParameterSetName = 'RemoteExecute')] 
        [ValidateNotNullOrEmpty()] 
        [string] $RemoteSqlInstance
    ,
    [Parameter(
            Mandatory=$true,
            ParameterSetName = 'RemoteExecute')] 
        [ValidateNotNullOrEmpty()] 
        [System.Data.DataTable] $ScriptsDataSet
    ,
    [Parameter(
            Mandatory=$false,
            ParameterSetName = 'RemoteExecute')] 
        [PSCredential] $RemoteSqlAuthCredential
    ,
    [Parameter(
            Mandatory=$false, 
            ParameterSetName = 'RemoteExecute')]
        [ValidateRange(0,65534)]
        [ValidateNotNull()]
        [int] $ConnectionTimeout
    ,
    [Parameter(
            Mandatory=$false, 
            ParameterSetName = 'RemoteExecute')]
        [ValidateRange(1,65535)]
        [ValidateNotNull()]
        [int] $QueryTimeout
    ,
    [Parameter(
            Mandatory=$false, 
            ParameterSetName = 'RemoteExecute')]
        [bool] $ExportToExcel
    ,
    [Parameter(
            Mandatory=$true,
            ParameterSetName = 'RemoteExecute')] 
        [ValidateNotNullOrEmpty()] 
        [string] $RootPath
    ,
    [Parameter(
            Mandatory=$true,
            ParameterSetName = 'RemoteExecute')] 
        [ValidateNotNullOrEmpty()] 
        [string] $LogFilePath
    )
<#
# test the Remote Script Block
[string] $RemoteServerName = "MyDatabaseServer.contoso.com,1433"
[string] $RemoteServerConnection = "Server=MyDatabaseServer.contoso.com,1433;Database=master;Integrated Security=true;Application Name=Script-Deployment;Connection Timeout=60;"
[System.Array] $ScriptFileList = @(
    '.\foo.sql',
    '.\man.sql'
    '.\choo.sql'
)
#>
    [string] $TestFilePathScript = "$($RootPath)\functions\Test-FilePath.ps1"
    . $TestFilePathScript

    # region possible-overheads
    # check if dbatools is installed
    if ($(Get-InstalledModule -Name dbatools -ErrorAction SilentlyContinue).Name -ne "dbatools") { 
        Write-Error "DBA Tools is not installed. Please install it as explained in the deployment instructions."
        return
    }

    # import modules - assuming that they must be installed as part of the project prerequisites
    if ($(Get-Module -Name dbatools).Name -ne "dbatools") { Import-Module -Name dbatools }

    # check if ImportExcel is installed
    if ($(Get-InstalledModule -Name ImportExcel -ErrorAction SilentlyContinue).Name -ne "ImportExcel") { 
        Write-Error "ImportExcel is not installed. Please install it as explained in the deployment instructions."
        return
    }
    # import modules - assuming that they must be installed as part of the project prerequisites
    if ($(Get-Module -Name ImportExcel).Name -ne "ImportExcel") { Import-Module -Name ImportExcel }
    # endregion possible-overheads

    [string] $LoggingFunctionScript = "$($RootPath)\functions\Write-Log.ps1"

    # check for existence of external files used by this script
    if ($false -eq $(Test-FilePath -FilePath $LoggingFunctionScript)) { return }

    # import function/s
    . $LoggingFunctionScript

    # --------------------------------------------------------------------------------
    # [string] $ApplicationName = "SqlMonitor"
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
    $Err = $null
    [int] $Success = 0
    [string] $ErrorMessage = ""
    [string] $InstanceServerName = ""
    [int] $QueryTimeout = 600
    
    # --------------------------------------------------------------------------------
    # check if any scripts (even though we checked in the parent/calling function)
    if ( $($ScriptsDataSet | Where-Object -Property ExecuteScript -ne -Value "").Count -gt 0 ) {
        Write-Log -LogFilePath $LogFilePath -LogEntry $("{0} : Start processing" -f $RemoteSqlInstance)

        # create the REMOTE connection object - https://docs.dbatools.io/Connect-DbaInstance
        $RemoteSqlConnection = New-Object Microsoft.SqlServer.Management.Smo.Server
        # use Windows Authentication
        if ($null -eq $RemoteSqlAuthCredential) { $RemoteSqlConnection = Connect-DbaInstance -SqlInstance $RemoteSqlInstance -ConnectTimeout $RemoteConnectTimeout -ClientName $HostName }
        # use SQL Authentication (NOTE: Username and Password sent in clear text - this is by design)
        else { $RemoteSqlConnection = Connect-DbaInstance -SqlInstance $RemoteSqlInstance -ConnectTimeout $RemoteConnectTimeout -ClientName $HostName -SqlCredential $RemoteSqlAuthCredential }
        Write-Log -LogFilePath $LogFilePath -LogEntry $("{0} : Connected" -f $RemoteSqlInstance)

        # get the value of the @@SERVERNAME variable - this is used for comparison purposes at various stages
        $SqlCmd = "SELECT COALESCE(CONVERT(nvarchar(128), SERVERPROPERTY('ServerName')), @@SERVERNAME) AS [ServerName];"
        $ResultDataSet = Invoke-DbaQuery -SqlInstance $RemoteSqlConnection -CommandType Text -Query $SqlCmd -QueryTimeout $QueryTimeout -As DataSet -EnableException # -ErrorAction Stop
        $InstanceServerName = $ResultDataSet.Tables[0].ServerName
        $ResultDataSet = $null

        # prepare Excel variables
        [string] $ReportFileName = $InstanceServerName.Replace("\", "$")
        [string] $ExportFolder = "$($RootPath)\Exports"
        [string] $ExportFileName = "$(Get-Date -Format 'yyyyMMdd_HHmmss')"
        [string] $ExportFilePath = "$($ExportFolder)\$($ReportFileName)_$($ExportFileName).xlsx"

        # start file loop
        foreach ($Script in $ScriptsDataSet) {
            try {
                $ScriptName = $Script.ScriptName
                $ExecuteScript = $Script.ExecuteScript
                Write-Log -LogFilePath $LogFilePath -LogEntry $("{0} : Preparing script ""{1}""" -f $RemoteSqlInstance, $ScriptName)

                # if at this stage the $ExecuteScript variable is still empty, then exit the loop and stop execution for this Instance
                if ([string]::IsNullOrEmpty($ExecuteScript)) { 
                    Write-Log -LogFilePath $LogFilePath -LogEntry $("{0} : The code for the ""{1}"" script could not be loaded." -f $RemoteSqlInstance, $ScriptName)
                    break
                }
                # good to go
                else {
                    # run the script
                    $SqlCmd = $ExecuteScript
                    try {
                        Write-Log -LogFilePath $LogFilePath -LogEntry $("{0} : Running script: {1}" -f $RemoteSqlInstance, $ScriptName)
                        # execute remote query and retrieve results, reusing the current connection object - http://docs.dbatools.io/Invoke-DbaQuery
                        $ResultDataSet = Invoke-DbaQuery -SqlInstance $RemoteSqlConnection -CommandType Text -Query $SqlCmd -QueryTimeout $QueryTimeout -As DataSet -EnableException # -ErrorAction Stop
                        $ErrorMessage = $null
                    }
                    catch { 
                        $ErrorMessage = $_.Exception.Message 
                        Write-Log -LogFilePath $LogFilePath -LogEntry $ErrorMessage
                    }

                    # check if the data retrieval was successful (i.e. no error)
                    if ([string]::IsNullOrEmpty($ErrorMessage)) {
                        # export results to Excel
                        if ($true -eq $ExportToExcel) {
                            # export to Excel
                            $ResultDataSet | Export-Excel -Path "$ExportFilePath" -AutoSize -FreezeTopRow -BoldTopRow -WorksheetName "$ScriptName"
                        }
                    }
                    else {
                        Write-Log -LogFilePath $LogFilePath -LogEntry $ErrorMessage
                    }
                }

                # report success
                $Success = 1
                $ErrorMessage = ""
                Write-Log -LogFilePath $LogFilePath -LogEntry $("{0} : {1} completed successfully" -f $RemoteSqlInstance, $ScriptName)
            }
            catch { 
                # Write-Host "Caught an exception:" -ForegroundColor Red
                # Write-Host "Exception type: $($_.Exception.GetType().FullName)" -ForegroundColor Red
                # Write-Host "Exception message: $($_.Exception.Message)" -ForegroundColor Red
                # Write-Host "Error: " $_.Exception -ForegroundColor Red
                $Err = $_
                $Success = 0
                $ErrorMessage = $($_.Exception.Message)
                Write-Log -LogFilePath $LogFilePath -LogEntry $("{0} : {1} failed with error ""{2}""" -f $RemoteSqlInstance, $ScriptName, $ErrorMessage)
                # break # On Error Exit the ForEach Loop (?)
                }
            finally { 
                # clean up
            }
        } # end foreach
        Write-Log -LogFilePath $LogFilePath -LogEntry $("{0} : All scripts processed. Review output for any errors." -f $RemoteSqlInstance)
        # free up memory
        # https://docs.dbatools.io/Disconnect-DbaInstance
        Disconnect-DbaInstance -SqlInstance $RemoteSqlInstance
    } # end check

    # return
    return $Err
}
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
[string] $InstanceLongPortName = ""
$timer = [System.Diagnostics.Stopwatch]::StartNew()

# Log Collector Start
# start jobs on all servers
ForEach($Instance in $ActualServerList) { 
    $InstanceLongPortName = $Instance
    Write-Log -LogFilePath $LogFilePath -LogEntry $("Processing instance: {0}" -f $InstanceLongPortName)
    # build connection string from template
    $RemoteServerConnection = $ConnectionStringTemplate -f $InstanceLongPortName, "master", "true", $ApplicationName, $ConnectionTimeout
    
    $ConcurrentQueue = New-Object System.Collections.Concurrent.ConcurrentQueue[string]
    $Runspace = [PowerShell]::Create()
    $null = $Runspace.AddScript($RemoteScriptBlock)
    $null = $Runspace.AddArgument($InstanceLongPortName)
    $null = $Runspace.AddArgument($RemoteServerConnection)
    # $null = $Runspace.AddArgument($ActualFileList)
    $null = $Runspace.AddArgument($ScriptsDataSet)
    $null = $Runspace.AddArgument($QueryTimeout)
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

[int] $secs = $timer.Elapsed.TotalSeconds
Write-Log -LogFilePath $LogFilePath -LogEntry "----------"
Write-Log -LogFilePath $LogFilePath -LogEntry "Servers processed: $($ActualServerList.Count)"
Write-Log -LogFilePath $LogFilePath -LogEntry "Duration: $secs seconds"

$RunspacePool.Close()
$RunspacePool.Dispose()

# clean up SQL connections and reset Default Runspace
[System.Data.SQLClient.SqlConnection]::ClearAllPools()
[System.Management.Automation.Runspaces.Runspace]::DefaultRunspace = $DefaultRunspace
#endregion

#region clean up

#endregion
