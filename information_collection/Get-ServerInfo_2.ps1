param(
    [Parameter(Position=1, Mandatory=$true)] [ValidateNotNullOrEmpty()] [string] $MonitorSqlInstance,
    [Parameter(Position=2, Mandatory=$true)] [ValidateNotNullOrEmpty()] [string] $MonitorDatabaseName,
    [Parameter(Position=3, Mandatory=$true)] [ValidateNotNull()] [int] $MonitorConnectTimeout = 30,
    [Parameter(Position=4, Mandatory=$true)] [ValidateNotNullOrEmpty()] [int] $MonitorProfile,
    [Parameter(Position=5, Mandatory=$true)] [ValidateNotNullOrEmpty()] [int] $MonitorProfileType,
    [Parameter(Position=6, Mandatory=$true)] [ValidateNotNull()] [int] $QueryTimeout = 360
)

#
# Usage: 
#     .\Get-ServerInfo.ps1 -MonitorSqlInstance "localhost,14330" -MonitorDatabaseName "SQLMonitor" -MonitorConnectTimeout 30 -MonitorProfile "Monitor" -MonitorProfileType "Daily" -QueryTimeout 360
#     Will run the function (if all input parameters are present and valid)
#

# import modules - assuming that they must be installed as part of the project prerequisites
if ($(Get-Module -Name dbatools).Name -ne "dbatools") { Import-Module -Name dbatools }

# get script file location
$CurrentPath = [System.IO.Path]::GetDirectoryName($myInvocation.MyCommand.Definition)

# import functions
. "$($CurrentPath)\functions\Write-Log.ps1"
. "$($CurrentPath)\functions\Test-NetworkConnection.ps1"

#------------------------------------------------------------# 

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
    
    # variables used for logging
    [string] $LogFolder = "$($(Get-Location).Path)\LOG"
    [string] $LogFileName = "$(Get-Date -Format 'yyMMddHHmmssfff')"
    [string] $LogFilePath = "$LogFolder\$LogFileName.log"
    # check and create logging subfolder/s
    if ($false -eq $(Test-Path -Path $LogFolder -PathType Container -ErrorAction SilentlyContinue)) {
        $null = New-Item -Path $LogFolder -ItemType Directory -Force -ErrorAction SilentlyContinue
    }

    #region set variables
    [string] $ScriptRoot = "$($CurrentPath)\scripts\"
    [bool] $IsAlive = $false
    [string] $SqlCmd = ""
    #endregion
    
    # start here
    Write-Log -LogFilePath $LogFilePath -LogEntry "=============================="
    Write-Log -LogFilePath $LogFilePath -LogEntry "Starting function: Get-ServerInfo"
    Write-Log -LogFilePath $LogFilePath -LogEntry "Server Name:       $MonitorSqlInstance"
    Write-Log -LogFilePath $LogFilePath -LogEntry "Database Name:     $MonitorDatabaseName"
    Write-Log -LogFilePath $LogFilePath -LogEntry "Connect Timeout:   $MonitorConnectTimeout"
    Write-Log -LogFilePath $LogFilePath -LogEntry "Profile Name:      $MonitorProfile"
    Write-Log -LogFilePath $LogFilePath -LogEntry "Profile Type:      $MonitorProfileType"
    Write-Log -LogFilePath $LogFilePath -LogEntry "Query Timeout:     $QueryTimeout"
    Write-Log -LogFilePath $LogFilePath -LogEntry "=============================="
    Write-Log -LogFilePath $LogFilePath -LogEntry ""
    Write-Log -LogFilePath $LogFilePath -LogEntry ""

    #region remote script - this is the workhorse
    $RemoteScriptBlock = { Get-Content "$($CurrentPath)\functions\Execute-Remote.ps1" -Raw }
    #endregion

    # create the MONITOR connection object - https://docs.dbatools.io/#Connect-DbaInstance
    # use Windows Authentication
    if ($null -eq $MonitorSqlAuthCredential) { $MonitorSqlConnection = Connect-DbaInstance -SqlInstance $MonitorqlInstance -ConnectTimeout $MonitorConnectTimeout -ClientName $HostName }
    # use SQL Authentication (NOTE: Username and Password sent in clear text - this is by design)
    else { $MonitorSqlConnection = Connect-DbaInstance -SqlInstance $MonitorSqlInstance -ConnectTimeout $MonitorConnectTimeout -ClientName $HostName -SqlCredential $MonitorSqlAuthCredential }

    # get profile (incl, script names and scripts) from MONITOR database - http://docs.dbatools.io/#Invoke-DbaQuery
    $SqlCmd = "dbo.uspGetProfile"
    # define the SQL command input parameters
    $QueryParameters = @{
        "ProfileName" = $MonitorProfile;
        "ProfileType" = $MonitorProfileType;
    };
    $ScriptsDataSet = Invoke-DbaQuery -SqlInstance $MonitorSqlConnection -Database $MonitorDatabaseName -CommandType StoredProcedure -Query $SqlCmd -SqlParameters $QueryParameters -QueryTimeout $QueryTimeout -As DataTable -EnableException -ErrorAction Stop
    
    # get list of servers from MONITOR database - http://docs.dbatools.io/#Invoke-DbaQuery
    $SqlCmd = "dbo.uspGetServers"
    $InstancesDataSet = Invoke-DbaQuery -SqlInstance $MonitorSqlConnection -CommandType StoredProcedure -Query $SqlCmd -QueryTimeout $QueryTimeout -As DataTable -EnableException -ErrorAction Stop

    # clear
    $SqlCmd = $null

	if ($Scripts.Table.Rows.Count -gt 0) {
        Foreach ($Instance in $InstancesDataSet) {
            [string] $ServerName = $Instance.ServerName
            [int] $TcpPort = $Instance.SqlTcpPort
            [string] $InstanceName = "$ServerName,$TcpPort"
            "{0} : Processing instance: {1}" -f $(Get-Date -Format "HH:mm:ss"), $InstanceName

            # check TCP connection on the specified port and stop execution on failure
            $IsAlive = Test-Port -HostName $ServerName -Port $ListeningPort
            if ($false -eq $IsAlive) { Write-Log -LogFilePath $LogFilePath -LogEntry "$InstanceName could not be reached." }

            # check if the connection test was successful
            if ($IsAlive -eq $true) {
# Runspace code starts here




                Foreach ($Script in $ScriptsDataSet) {
                    $ScriptName = $ScriptRoot + $Script.ScriptName + ".sql"
                    $TableName = $Script.ScriptName
                    $IntervalMinutes = $Script.IntervalMinutes
                    # the script that should be executed, retrieved from the database
                    $ExecuteScript = $Result.ExecuteScript

                    # check that the script file exists
                    if (Test-Path $ScriptName -PathType Leaf) {
                        # check when the script was last run and compare to the pre-defined value for how many minutes should have elapsed
                        # this will avoid that say, a script that should run Monthly is run multiple times during the month
                        # the COALESCE function will either return the value of the most recent RecordCreated column for that server OR the value 600,000 (which is more than 1 year in minutes)
                        $SqlCmd = "SELECT COALESCE(DATEDIFF(N, MAX([RecordCreated]), SYSDATETIMEOFFSET()), 600000) AS [MinutesElapsed] FROM [$($ProfileName)].[$($TableName)] WHERE [ServerName] = @ServerName AND [RecordStatus] = 'A';"
                        # define the SQL command input parameters
                        $QueryParameters = @{
                            "ServerName" = $ServerName;
                        };
                        $ResultDataSet = Invoke-DbaQuery -SqlInstance $MonitorSqlConnection -Database $MonitorDatabaseName -CommandType Text -Query $SqlCmd -SqlParameters $QueryParameters -QueryTimeout $QueryTimeout -As DataTable -EnableException -ErrorAction Stop
                        $MinutesElapsed = $ResultDataSet.MinutesElapsed
                        $ResultDataSet = $null

                        # compare values and handle processing (greater than or equal to comparison)
                        if ($MinutesElapsed -ge $IntervalMinutes) {

                            # run any script marked for pre-execution
                            $SqlCmd = $Script.PreExecuteScript
                            # NOTE: if NOT IsNullOrEmpty...
                            if (![string]::IsNullOrEmpty($SqlCmd)) {
                                # define the SQL command input parameters
                                $QueryParameters = @{
                                    "ServerName" = $ServerName;
                                };
                                $PreExecuteResult = Invoke-DbaQuery -SqlInstance $MonitorSqlConnection -Database $MonitorDatabaseName -CommandType Text -Query $SqlCmd -SqlParameters $QueryParameters -QueryTimeout $QueryTimeout -As DataTable -EnableException -ErrorAction Stop
                            }

                            "{0} : Running script:    {1}" -f $(Get-Date -Format "HH:mm:ss"), $ScriptName
                            # run the script retrieved from the database, otherwise load it from the file
                            if ([string]::IsNullOrEmpty($ExecuteScript)) {
                                $Sql = Get-Content -Path $ScriptName -Raw
                            }
                            else {
                                $Sql = $ExecuteScript
                            }
                            # replace the script parameter with the result obtained
                            # NOTE: if NOT IsNullOrEmpty...
                            if (![string]::IsNullOrEmpty($PreExecuteResult)) {
                                $Sql = $Sql -f $PreExecuteResult.Output
                            }
                            # run and store the output in a data table variable
                            try {
                                $Result = Invoke-Sqlcmd2 -ServerInstance $InstanceName -Database master -Query $Sql.ToString() -QueryTimeout $QueryTimeout
                                $ErrorMessage = $null
                            }
                            catch {
                                $ErrorMessage = $_.Exception.Message
                                Write-Warning $ErrorMessage
                            }

                            # check if the data retrieval was successful
                            if ([string]::IsNullOrEmpty($ErrorMessage)) {
                                $dt = $Result | Out-DataTable
                                $dtRowCount = $dt.Rows.Count

                                # update the status for older data
                                $Sql = "IF EXISTS (SELECT 1 FROM $($ProfileName).$($TableName) WHERE [ServerName] = '$($ServerName)' AND [RecordStatus] = 'A') UPDATE $($ProfileName).$($TableName) SET [RecordStatus] = 'H' WHERE [ServerName] = '$($ServerName)' AND [RecordStatus] = 'A';"
                                Invoke-Sqlcmd2 -ServerInstance $ServerInstance -Database $Database -Query $Sql -QueryTimeout $QueryTimeout

                                # write data extracted from remote server to the central table
                                if ($dtRowCount -gt 0) {
                                    Write-DataTable -Data $dt -ServerInstance $ServerInstance -Database $Database -TableName "$($ProfileName).$($TableName)"
                                }
                            }
                            # clean up
                            $ErrorMessage = $null
                            $ExecuteScript = $null
                            $Result = $null
                            $dt = $null
                            $dtRowCount = 0
                            $PreExecuteResult = $null
                        }
                        # script has been executed against the current server in the past N minutes
                        else {
                            $ts =  [timespan]::fromminutes($MinutesElapsed)
                            $age = New-Object DateTime -ArgumentList $ts.Ticks

                            $msg = "" 

                            if ($($age.Year-1) -gt 0) { $msg += " " + $($age.Year-1).ToString() + " Years" }
                            if ($($age.Month-1) -gt 0) { $msg += " " + $($age.Month-1).ToString() + " Months" }
                            if ($($age.Day-1) -gt 0) { $msg += " " + $($age.Day-1).ToString() + " days" }
                            if ($($age.Hour) -gt 0) { $msg += " " + $($age.Hour).ToString() + " hours" }
                            if ($($age.Minute) -gt 0) { $msg += " " + $($age.Minute).ToString() + " minutes" }
                            #if ($($age.second) -gt 0) { $msg += " " + $($age.second).ToString() + " seconds" }

                            $msg += " ago"

                            "{0} : Script {1} was last run$msg." -f $(Get-Date -Format "HH:mm:ss"), $ScriptName
                        }
                    } # if
                    # script file does not exist
                    else {
                        "{0} : Script {1} not found." -f $(Get-Date -Format "HH:mm:ss"), $ScriptName
                    }
                    $ScriptName = $null
                    $TableName = $null
                    $IntervalMinutes = $null
                } # foreach
            } # if
            "{0} : Completed server:  {1}" -f $(Get-Date -Format "HH:mm:ss"), $InstanceName
            "{0} : ------------------------------ " -f $(Get-Date -Format "HH:mm:ss")
            $ServerName = $null
            $InstanceName = $null
        }
    }
    else {
        Write-Warning "No scripts found for the $ProfileType profile!"
    }
    "{0} : Done" -f $(Get-Date -Format "HH:mm:ss")
    "{0} : ============================== " -f $(Get-Date -Format "HH:mm:ss")
}

Clear-Host
# run this only if the parameters have been passed to the script
# interface implemented to be called from Windows Task Scheduler or similar applications
if (($ServerInstance -ne '') -and ($Database -ne '') -and ($ProfileName -ne '') -and ($ProfileType -ne '')) {
    Get-ServerInfo -ServerInstance $ServerInstance -Database $Database -ProfileName $ProfileName -ProfileType $ProfileType -QueryTimeout $QueryTimeout
}
# otherwise, do nothing
