param(
    [Parameter(Position=0, Mandatory=$true)] [ValidateNotNullOrEmpty()] [System.Data.SqlClient.SQLConnection] $MonitorSqlConnection,
    [Parameter(Position=1, Mandatory=$true)] [ValidateNotNullOrEmpty()] [string] $MonitorDatabaseName,
    [Parameter(Position=2, Mandatory=$true)] [ValidateNotNullOrEmpty()] [string] $MonitorStagingSchema,

    [Parameter(Position=3, Mandatory=$true)] [ValidateNotNullOrEmpty()] [string] $RemoteSqlInstance,
    [Parameter(Position=4, Mandatory=$false)] [PSCredential] $RemoteSqlAuthCredential,
    [Parameter(Position=5, Mandatory=$true)] [ValidateNotNullOrEmpty()] [System.Data.DataTable] $ScriptsDataSet,

    [Parameter(Position=6, Mandatory=$true)] [ValidateNotNullOrEmpty()] [string] $LogFilePath
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

# region possible-overheads
# check if dbatools is installed
if ($(Get-InstalledModule -Name dbatools -ErrorAction SilentlyContinue).Name -ne "dbatools") { 
    Write-Error "DBA Tools is not installed. Please install it as explained in the deployment instructions."
    return
}

# import modules - assuming that they must be installed as part of the project prerequisites
if ($(Get-Module -Name dbatools).Name -ne "dbatools") { Import-Module -Name dbatools }
# endregion possible-overheads

# get script file location
$CurrentPath = [System.IO.Path]::GetDirectoryName($myInvocation.MyCommand.Definition)

# check for existence of external files used by this script
[string] $SupportFile = ""
$SupportFile = "$($CurrentPath)\Write-Log.ps1"
if ( $false -eq $(Test-Path $SupportFile -PathType Leaf) ) { Write-Error $("The required file {0} does not exist." -f $SupportFile) }

# import functions
. "$($CurrentPath)\Write-Log.ps1"

# --------------------------------------------------------------------------------
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
$Err = $null
[int] $Success = 0
[string] $ErrorMessage = ""
[int] $MinutesElapsed = 600000
[int] $IntervalMinutes = 0

# --------------------------------------------------------------------------------
# check if any scripts (even though we checked in the parent/calling function)
if ( $($ScriptsDataSet | Where-Object -Property ExecuteScript -ne -Value "").Count -eq 0 ) {
    Write-Log -LogFilePath $LogFilePath -LogEntry $("{0} : Start proessing" -f $RemoteSqlInstance)

    # create the REMOTE connection object - https://docs.dbatools.io/Connect-DbaInstance
    # use Windows Authentication
    if ($null -eq $RemoteSqlAuthCredential) { $RemoteSqlConnection = Connect-DbaInstance -SqlInstance $RemoteSqlInstance -ConnectTimeout $RemoteConnectTimeout -ClientName $HostName -ApplicationName $ApplicationName }
    # use SQL Authentication (NOTE: Username and Password sent in clear text - this is by design)
    else { $RemoteSqlConnection = Connect-DbaInstance -SqlInstance $RemoteSqlInstance -ConnectTimeout $RemoteConnectTimeout -ClientName $HostName -ApplicationName $ApplicationName -SqlCredential $RemoteSqlAuthCredential }
    Write-Log -LogFilePath $LogFilePath -LogEntry $("{0} : Connected" -f $RemoteSqlInstance)

    # start file loop
    foreach ($Script in $ScriptsDataSet) {
        try {
            $ScriptName = $Script.ScriptName
            Write-Log -LogFilePath $LogFilePath -LogEntry $("{0} : Preparing script ""{1}""" -f $RemoteSqlInstance, $ScriptName)
            $TargetTableName = $ScriptName
            $IntervalMinutes = $Script.IntervalMinutes
            # the script that should be executed, retrieved from the database
            $ExecuteScript = $Script.ExecuteScript

            # if at this stage the $ExecuteScript variable is still empty, then exit the loop and stop execution for this Instance
            if ([string]::IsNullOrEmpty($ExecuteScript)) { 
                Write-Log -LogFilePath $LogFilePath -LogEntry $("{0} : The code for the ""{1}"" script could not be loaded." -f $RemoteSqlInstance, $ScriptName)
                break
            }
            # good to go
            else {
                # check when the script was last run and compare to the pre-defined value for how many minutes should have elapsed
                # this will avoid that say, a script that should run Monthly is run multiple times during the month
                # the COALESCE function will either return the value of the most recent RecordCreated column for that server OR the value 600,000 (which is more than 1 year in minutes)
                # TODO: Convert this to a stored procedure
                $SqlCmd = "
SELECT COALESCE(DATEDIFF(N, MAX([RecordCreated]), SYSDATETIMEOFFSET()), 600000) AS [MinutesElapsed] 
FROM [{0}].[{1}] 
WHERE [ServerName] = @ServerName 
AND [RecordStatus] = 'A';" -f $MonitorStagingSchema, $TargetTableName
                # define the SQL command input parameters
                $QueryParameters = @{
                    "ServerName" = $ServerName;
                };
                $ResultDataSet = Invoke-DbaQuery -SqlInstance $MonitorSqlConnection -Database $MonitorDatabaseName -CommandType Text -Query $SqlCmd -SqlParameters $QueryParameters -QueryTimeout $QueryTimeout -As DataTable -EnableException -ErrorAction Stop
                $MinutesElapsed = $ResultDataSet.MinutesElapsed
                # check result and set a default value
                if ($null -eq $MinutesElapsed) { $MinutesElapsed = 600000 }
                $ResultDataSet = $null

                # compare values and handle processing (greater than or equal to comparison)
                if ($MinutesElapsed -ge $IntervalMinutes) {
                    # run any script marked for pre-execution
                    $SqlCmd = $Script.PreExecuteScript
                    # NOTE: if NOT IsNullOrEmpty...
                    if (![string]::IsNullOrEmpty($SqlCmd)) {
                        # define the SQL command input parameters
                        # NOTE 1: Every PreExecuteScript command MUST have a single filtering "@ServerName" parameter
                        # NOTE 2: Every PreExecuteScript command MUST always return a single datetime value cast as a VARCHAR(25) data type, with the column name being "Output"
                        $QueryParameters = @{
                            "ServerName" = $ServerName;
                        };
                        Write-Log -LogFilePath $LogFilePath -LogEntry $("{0} : Running PreExecuteScript for: {1}" -f $RemoteSqlInstance, $ScriptName)
                        $PreExecuteResult = Invoke-DbaQuery -SqlInstance $MonitorSqlConnection -Database $MonitorDatabaseName -CommandType Text -Query $SqlCmd -SqlParameters $QueryParameters -QueryTimeout $QueryTimeout -As DataTable -EnableException -ErrorAction Stop
                    }

                    # run the script retrieved from the database or from file
                    $SqlCmd = $ExecuteScript
                    # replace the script parameter with the result obtained
                    # NOTE: if NOT IsNullOrEmpty...
                    if (![string]::IsNullOrEmpty($PreExecuteResult)) {
                        $SqlCmd = $SqlCmd -f $PreExecuteResult.Output
                    }

                    try {
                        Write-Log -LogFilePath $LogFilePath -LogEntry $("{0} : Running script: {1}" -f $RemoteSqlInstance, $ScriptName)
                        # execute remote query and retrieve results, reusing the current connection object - http://docs.dbatools.io/Invoke-DbaQuery
                        $ResultDataSet = Invoke-DbaQuery -SqlInstance $RemoteSqlConnection -CommandType Text -Query $SqlCmd -QueryTimeout $QueryTimeout -As DataSet -EnableException # -ErrorAction Stop
                        $ErrorMessage = $null
                    }
                    catch { $ErrorMessage = $_.Exception.Message }

                    # check if the data retrieval was successful (i.e. no error)
                    if ([string]::IsNullOrEmpty($ErrorMessage)) {
                        # update the status for older data
                        # TODO: Convert this to a stored procedure
                        $SqlCmd = "
IF EXISTS (SELECT 1 FROM [{0}].[{1}] WHERE [ServerName] = '{2}}' AND [RecordStatus] = 'A') 
UPDATE [{0}].[{1}] SET [RecordStatus] = 'H' WHERE [ServerName] = '{2}}' AND [RecordStatus] = 'A';" -f $MonitorStagingSchema, $TargetTableName, $ServerName
                        Write-Log -LogFilePath $LogFilePath -LogEntry $("{0} : Update the status for older data on [{1}].[{2}]" -f $RemoteSqlInstance, $MonitorStagingSchema, $TargetTableName)
                        Invoke-DbaQuery -SqlInstance $MonitorSqlConnection -Database $MonitorDatabaseName -CommandType Text -Query $SqlCmd -QueryTimeout $QueryTimeout -As DataTable -EnableException -ErrorAction Stop
                    
                        if ($ResultDataSet.Tables[0].Rows.Count -gt 0) {
                            # write data extracted from remote server to the central table
                            Write-Log -LogFilePath $LogFilePath -LogEntry $("{0} : Write data extracted from remote server to the central table [{1}].[{2}]" -f $RemoteSqlInstance, $MonitorStagingSchema, $TargetTableName)
                            $ResultDataSet | Write-DbaDbTableData -SqlInstance $MonitorSqlConnection -Database $MonitorDatabaseName -Table $TargetTableName -Schema $MonitorStagingSchema -KeepNulls -EnableException # -ErrorAction Stop
                            # NOTE: see documentation notes regarding performmance of Write-DbaDbTableData wen using the DataSet data type as the InputObject
                        }
                    }
                    else {
                        Write-Log -LogFilePath $LogFilePath -LogEntry $ErrorMessage
                    }
                }
                # script has been executed against the current server in the past N minutes
                else {
                    $LastRunTimespan =  [timespan]::FromMinutes($MinutesElapsed)
                    $LastRunAge = New-Object DateTime -ArgumentList $LastRunTimespan.Ticks
                    [string] $LastRunMessage = ""

                    if ($($LastRunAge.Year-1) -gt 0) { $LastRunMessage += " " + $($LastRunAge.Year-1).ToString() + " year" + $( if ($LastRunAge.Year-1 -gt 1) {'s'} ) }
                    if ($($LastRunAge.Month-1) -gt 0) { $LastRunMessage += " " + $($LastRunAge.Month-1).ToString() + " month" + $( if ($LastRunAge.Month-1 -gt 1) {'s'} ) }
                    if ($($LastRunAge.Day-1) -gt 0) { $LastRunMessage += " " + $($LastRunAge.Day-1).ToString() + " day" + $( if ($LastRunAge.Day -gt 1) {'s'} ) }
                    if ($($LastRunAge.Hour) -gt 0) { $LastRunMessage += " " + $($LastRunAge.Hour).ToString() + " hour" + $( if ($LastRunAge.Hour-1 -gt 1) {'s'} ) }
                    if ($($LastRunAge.Minute) -gt 0) { $LastRunMessage += " " + $($LastRunAge.Minute).ToString() + " minute" + $( if ($LastRunAge.Minute-1 -gt 1) {'s'} ) }
                    #if ($($LastRunAge.second) -gt 0) { $LastRunMessage += " " + $($LastRunAge.second).ToString() + " seconds" + $( if ($LastRunAge.Second-1 -gt 1) {'s'} ) }
                    # remove extra leading and trailing spaces
                    $LastRunMessage += $(" ago").Trim()
                    Write-Log -LogFilePath $LogFilePath -LogEntry $("{0} : Script {1} was last run {2}." -f $RemoteSqlInstance, $ScriptName, $LastRunMessage)
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
            Write-Log -LogFilePath $LogFilePath -LogEntry $("{0}: {1} failed with error ""{2}""" -f $RemoteSqlInstance, $SqlFile.Name.ToString(), $ErrorMessage)
            # break # On Error Exit the ForEach Loop (?)
            }
        finally { 
            # clean up
        }
    } # end foreach
    Write-Log -LogFilePath $LogFilePath -LogEntry $("{0}: Completed" -f $RemoteSqlInstance)
    # free up memory
    # https://docs.dbatools.io/Disconnect-DbaInstance
    Disconnect-DbaInstance -SqlInstance $RemoteSqlInstance
} # end check

# return
return $Err