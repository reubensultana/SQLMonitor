param(
    [Parameter(Mandatory=$true)] [String]$ServerName,
    [Parameter(Mandatory=$true)] [String]$ScriptsFolder,
    [Parameter(Mandatory=$true)] [String]$OutputPath
)
#
# Usage: .\Export-ServerInfo.ps1 -ServerName "localhost,1433" -ScriptsFolder ".\scripts" -OutputPath "C:\temp"
#
Clear-Host

# Global params
$ServerInstance = $ServerName
$Database = "master" # <-- to avoid connecting to a database which does not exist

# build an array of files, in the order they have to be executed
$filelist = New-Object System.Collections.ArrayList
# read list of files from the "configuration" text file
$ScriptFiles = Get-ChildItem -Path $ScriptsFolder -Filter *.sql | Select-Object Name
# verify that the files adhere to specific criteria
ForEach ($ScriptFile in $ScriptFiles) {
    $ScriptFile = "$ScriptsFolder\$($ScriptFile.Name)";
    # only SQL files allowed; check if the file exists
    if (($ScriptFile -like "*.sql") -and (Test-Path $ScriptFile -PathType Leaf)) {
        # NOTE: The "> $null" part is to remove the array item index output
        $filelist.Add($ScriptFile.ToString()) > $null
    }
    else { "Script '{0}' could not be found" -f $ScriptFile }
}

# read and run scripts against the SQL Server instance
if ($filelist.Count -gt 0) {
    # load and run the scripts listed in the array
    "{0} : Starting execution of {1} database scripts on {2}" -f $(Get-Date -Format "HH:mm:ss"), $filelist.Count, $ServerInstance
    "{0} : ---------------------------------------------------------------------------" -f $(Get-Date -Format "HH:mm:ss")
    # start loop
    $OutputPath = "$OutputPath\$ServerName"
    New-Item -Path $OutputPath -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null;
    ForEach ($script In $filelist) {
        $scriptexecpath = $script.ToString()
        # check if the file exists, again
        if (Test-Path $scriptexecpath -PathType Leaf) {
            $sql = Get-Content -Path $scriptexecpath -Raw
            $sql = $sql -f ((Get-Date).AddDays(5)).ToString("yyyy-MM-dd");
            "{0} : Running script: {1}" -f $(Get-Date -Format "HH:mm:ss"), $scriptexecpath
            try { 
                Invoke-Sqlcmd -ServerInstance $ServerInstance -Database $Database -Query $sql -QueryTimeout 300 | `
                    Export-Csv -Path ($scriptexecpath.Replace(".sql", ".csv").Replace($ScriptsFolder, $OutputPath)) -Delimiter "," -NoClobber -NoTypeInformation
            }
            catch { break } # On Error, Exit the ForEach Loop
        }
        else { "{0} : Script '{1}' could not be found" -f $(Get-Date -Format "HH:mm:ss"), $scriptexecpath }
    }
    # end loop
    "{0} : ---------------------------------------------------------------------------" -f $(Get-Date -Format "HH:mm:ss")
    "{0} : Script execution complete" -f $(Get-Date -Format "HH:mm:ss")
}

# deallocate variables
$ServerInstance = $null
$Database = $null
$filelist = $null
$script = $null
$scriptexecpath = $null
$sql = $null