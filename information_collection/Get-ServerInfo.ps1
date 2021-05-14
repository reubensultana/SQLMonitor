param([String]$ServerName = '',
	  [String]$DatabaseName = '',
      [String]$MonitorProfile = '',
      [String]$MonitorProfileType = '',
	  [String]$QueryTimeout = 30)

# 
# Usage: 
#     .\Get-ServerInfo.ps1 -ServerName "Server Name" -DatabaseName "SQL Monitor Database" -MonitorProfile "Monitor Profile" -MonitorProfileType "Profile Type"
#     Will run the function (if all input parameters are present and valid)
#

# import functions
.\functions\Write-Log.ps1
.\functions\Execute-Remote.ps1

# local variables declared and set to store values passed into script since two of the latter were being initialised when declared in one of the imported scripts
$ServerInstance = $ServerName
$Database = $DatabaseName
$ProfileName = $MonitorProfile
$ProfileType = $MonitorProfileType

# Global params
$CurrentPath = Get-Location
. "$($CurrentPath)\Community_Functions.ps1"
. "$($CurrentPath)\Test-NetworkConnection.ps1"

#------------------------------------------------------------# 

function Get-ServerInfo() {
    [CmdletBinding()]  
    param(  
    [Parameter(Position=0, Mandatory=$true)] [string]$ServerInstance, 
    [Parameter(Position=1, Mandatory=$true)] [string]$Database,
    [Parameter(Position=2, Mandatory=$true)] [string]$ProfileName,
    [Parameter(Position=3, Mandatory=$true)] [string]$ProfileType,
	[Parameter(Position=4, Mandatory=$false)] [string]$QueryTimeout = 360
    )  
    
    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo") | out-null
    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.ConnectionInfo") | out-null
    
    # start here
    "{0} : ============================== " -f $(Get-Date -Format "HH:mm:ss")
    "{0} : Starting function: Get-ServerInfo" -f $(Get-Date -Format "HH:mm:ss")
    "{0} : Server Name:       {1}" -f $(Get-Date -Format "HH:mm:ss"), $ServerInstance
    "{0} : Database Name:     {1}" -f $(Get-Date -Format "HH:mm:ss"), $Database
    "{0} : Profile Name:      {1}" -f $(Get-Date -Format "HH:mm:ss"), $ProfileName
    "{0} : Profile Type:      {1}" -f $(Get-Date -Format "HH:mm:ss"), $ProfileType
	"{0} : Query Timeout:     {1}" -f $(Get-Date -Format "HH:mm:ss"), $QueryTimeout
    "{0} : ============================== " -f $(Get-Date -Format "HH:mm:ss")
    
    #region set variables
    # $ScriptRoot = "$($CurrentPath)\scripts\"
    $ScriptRoot = ".\scripts\"
    [bool] $IsAlive = $false
    #endregion

    # variables used for logging
    [string] $LogFolder = "$($(Get-Location).Path)\LOG"
    [string] $LogFileName = "$(Get-Date -Format 'yyMMddHHmmssfff')"
    [string] $LogFilePath = "$LogFolder\$LogFileName.log"
    # check and create logging subfolder/s
    if ($false -eq $(Test-Path -Path $LogFolder -PathType Container -ErrorAction SilentlyContinue)) {
        $null = New-Item -Path $LogFolder -ItemType Directory -Force -ErrorAction SilentlyContinue
    }

    #region remote script - this is the workhorse
    $RemoteScriptBlock = { Get-Content }

    # get profile (incl, script names and scripts)
    $Sql = "EXEC dbo.uspGetProfile '{0}', '{1}';" -f $ProfileName, $ProfileType
    $Scripts = Invoke-Sqlcmd2 -ServerInstance $ServerInstance -Database $Database -Query $Sql -QueryTimeout $QueryTimeout

    # get list of servers
    $Sql = "EXEC dbo.uspGetServers;"
    $ServerInstances = Invoke-Sqlcmd2 -ServerInstance $ServerInstance -Database $Database -Query $Sql -QueryTimeout $QueryTimeout
	
    # clear
    $Sql = $null

	if ($Scripts.Table.Rows.Count -gt 0) {
        Foreach ($Server in $ServerInstances) {
            $ServerName = $Server.ServerName
            $TcpPort = $Server.SqlTcpPort
            $InstanceName = "$ServerName,$TcpPort"
            "{0} : Processing server: {1}" -f $(Get-Date -Format "HH:mm:ss"), $InstanceName

            # check TCP connection on the specified port and stop execution on failure
            try { (New-Object System.Net.Sockets.TcpClient).Connect($ServerName,$ListeningPort); $IsAlive = $true } 
            catch { $IsAlive = $false; Write-Log -LogFilePath $LogFilePath -LogEntry "$InstanceName could not be reached."}
            finally {} 

            # check if the connection test was successful
            if ($IsAlive -eq $true) {
                Foreach ($Script in $Scripts) {
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
                        $Sql = "SELECT COALESCE(DATEDIFF(N, MAX([RecordCreated]), CURRENT_TIMESTAMP), 600000) AS [MinutesElapsed] FROM $($ProfileName).$($TableName) WHERE [ServerName] = '$($ServerName)' AND [RecordStatus] = 'A';"
                        $Result = Invoke-Sqlcmd2 -ServerInstance $ServerInstance -Database $Database -Query $Sql -QueryTimeout $QueryTimeout
                        $MinutesElapsed = $Result.MinutesElapsed
                        $Result = $null

                        # compare values and handle processing (greater than or equal to comparison)
                        if ($MinutesElapsed -ge $IntervalMinutes) {

                            # run any script marked for pre-execution
                            $PreExecuteScript = $Script.PreExecuteScript
                            # NOTE: if NOT IsNullOrEmpty...
                            if (![string]::IsNullOrEmpty($PreExecuteScript)) {
                                # replace the parameter with the server name
                                $PreExecuteScript = $PreExecuteScript -f $ServerName
                                # execute the query against the monitoring database
                                $PreExecuteResult = Invoke-Sqlcmd2 -ServerInstance $ServerInstance -Database $Database -Query $PreExecuteScript -QueryTimeout $QueryTimeout
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

                                if ($dtRowCount -gt 0) {
                                    # workaround to remove excess columns added when converting to data table - start
                                    $dt.Columns.Remove("RowError")
                                    $dt.Columns.Remove("RowState")
                                    $dt.Columns.Remove("Table")
                                    $dt.Columns.Remove("ItemArray")
                                    $dt.Columns.Remove("HasErrors")
                                    # workaround to remove excess columns added when converting to data table - start
                                }

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
                            $PreExecuteScript = ""
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
