# Global params
$CurrentPath = Get-Location
. "$($CurrentPath)\Community_Functions.ps1"

Function Get-ServerInfo() {
    [CmdletBinding()]  
    param(  
    [Parameter(Position=0, Mandatory=$true)] [string]$ServerInstance, 
    [Parameter(Position=1, Mandatory=$true)] [string]$Database,
    [Parameter(Position=2, Mandatory=$true)] [string]$ProfileName,
    [Parameter(Position=3, Mandatory=$true)] [string]$ProfileType
    )  
    
    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo") | out-null
    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.ConnectionInfo") | out-null
    
    # start here
    "{0} : Starting function: Get-ServerInfo" -f $(Get-Date -Format "HH:mm:ss")
    "{0} : Server Name:       {1}" -f $(Get-Date -Format "HH:mm:ss"), $ServerInstance
    "{0} : Database Name:     {1}" -f $(Get-Date -Format "HH:mm:ss"), $Database
    "{0} : Profile Name:      {1}" -f $(Get-Date -Format "HH:mm:ss"), $ProfileName
    "{0} : Profile Type:      {1}" -f $(Get-Date -Format "HH:mm:ss"), $ProfileType
    "{0} : ============================== " -f $(Get-Date -Format "HH:mm:ss")
    
    # $scriptroot = "$($CurrentPath)\scripts\"
    $scriptroot = ".\scripts\"

    # get profile (incl, script names and scripts)
    $sql = "EXEC dbo.uspGetProfile '{0}', '{1}'" -f $ProfileName, $ProfileType
    $scripts = Invoke-Sqlcmd2 -ServerInstance $ServerInstance -Database $Database -Query $sql

    # get list of servers
    $sql = "SELECT ServerName, SqlTcpPort FROM [dbo].[MonitoredServers] WHERE [RecordStatus] = 'A' ORDER BY ServerOrder ASC, ServerName ASC;"
    $ServerInstances = Invoke-Sqlcmd2 -ServerInstance $ServerInstance -Database $Database -Query $sql

    # clear
    $sql = $null

    Foreach ($Server in $ServerInstances) {
        $ServerName = $Server.ServerName
        $InstanceName = "$($Server.ServerName),$($Server.SqlTcpPort)"
        "{0} : Processing server: {1}" -f $(Get-Date -Format "HH:mm:ss"), $ServerName

        Foreach ($script in $scripts) {
            $scriptname = $scriptroot + $script.ScriptName + ".sql"
            $tablename = $script.ScriptName
            $intervalminutes = $script.IntervalMinutes
            # the script that should be executed, retrieved from the database
            $executescript = $result.ExecuteScript

            # check that the script file exists
            if (Test-Path $scriptname -PathType Leaf) {
                # check when the script was last run and compare to the pre-defined value for how many minutes should have elapsed
                # this will avoid that say, a script that should run Monthly is run multiple times during the month
                # the COALESCE function will either return the value of the most recent RecordCreated column for that server OR the value 600,000 (which is more than 1 year in minutes)
                $sql = "SELECT COALESCE(DATEDIFF(N, MAX([RecordCreated]), CURRENT_TIMESTAMP), 600000) AS [MinutesElapsed] FROM $($ProfileName).$($tablename) WHERE [ServerName] = '$($ServerName)';"
                $result = Invoke-Sqlcmd2 -ServerInstance $ServerInstance -Database $Database -Query $sql
                $minuteselapsed = $result.MinutesElapsed
                $result = $null

                # compare values and handle processing (greater than or equal to comparison)
                if ($minuteselapsed -ge $intervalminutes) {

                    # run any script marked for pre-execution
                    $preexecutescript = $script.PreExecuteScript
                    # NOTE: if NOT IsNullOrEmpty...
                    if (![string]::IsNullOrEmpty($preexecutescript)) {
                        # replace the parameter with the server name
                        $preexecutescript = $preexecutescript -f $ServerName
                        # execute the query against the monitoring database
                        $preexecuteresult = Invoke-Sqlcmd2 -ServerInstance $ServerInstance -Database $Database -Query $preexecutescript
                    }

                    "{0} : Running script:    {1}" -f $(Get-Date -Format "HH:mm:ss"), $scriptname
                    # run the script retrieved from the database, otherwise load it from the file
                    if ([string]::IsNullOrEmpty($runscript)) {
                        $sql = Get-Content -Path $scriptname -Raw
                    }
                    else {
                        $sql = $runscript
                    }
                    # replace the script parameter with the result obtained
                    # NOTE: if NOT IsNullOrEmpty...
                    if (![string]::IsNullOrEmpty($preexecuteresult)) {
                        $sql = $sql -f $preexecuteresult.Output
                    }
                    # run and store the output in a data table variable
                    $result = Invoke-Sqlcmd2 -ServerInstance $InstanceName -Database master -Query $sql.ToString()
                    $dt = $result | Out-DataTable
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
                    $sql = "UPDATE $($ProfileName).$($tablename) SET [RecordStatus] = 'H' WHERE [ServerName] = '$($ServerName)' AND [RecordStatus] = 'A';"
                    Invoke-Sqlcmd2 -ServerInstance $ServerInstance -Database $Database -Query $sql

                    # write data extraced from remote server to central table
                    if ($dtRowCount -gt 0) {
                        Write-DataTable -Data $dt -ServerInstance $ServerInstance -Database $Database -TableName "$($ProfileName).$($tablename)"
                    }
                    # clean up
                    $runscript = $null
                    $executescript = $null
                    $dt = $null
                    $dtRowCount = 0
                    $preexecutescript = ""
                    $preexecuteresult = $null
                }
                # script has been executed against the current server in the past N minutes
                else {
                    "{0} : Script {1} has already been run within the pre-defined timeframes." -f $(Get-Date -Format "HH:mm:ss"), $scriptname
                }
            }
            # script file does not exist
            else {
                "{0} : Script {1} not found." -f $(Get-Date -Format "HH:mm:ss"), $scriptname
            }
            $scriptname = $null
            $tablename = $null
            $intervalminutes = $null
        }
        "{0} : Completed server:  {1}" -f $(Get-Date -Format "HH:mm:ss"), $ServerName
        "{0} : ------------------------------ " -f $(Get-Date -Format "HH:mm:ss")
        $ServerName = $null
        $InstanceName = $null
    }
    "{0} : Done" -f $(Get-Date -Format "HH:mm:ss")
    "{0} : ============================== " -f $(Get-Date -Format "HH:mm:ss")
}
