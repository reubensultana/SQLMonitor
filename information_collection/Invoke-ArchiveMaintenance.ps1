param([String]$ServerName = '',
	  [String]$DatabaseName = '')

# 
# Usage: 
#     .\Invoke-ArchiveMaintenance.ps1 -ServerName "Server Name" -DatabaseName "SQL Monitor Database"
#     Will run the function (if all input parameters are present and valid)
#

# Global params
$CurrentPath = Get-Location
. "$($CurrentPath)\Community_Functions.ps1"

#------------------------------------------------------------# 

function Invoke-ArchiveMaintenance () {
    [CmdletBinding()]  
    param(  
    [Parameter(Position=0, Mandatory=$true)] [string]$ServerInstance, 
    [Parameter(Position=1, Mandatory=$true)] [string]$Database
    )  
    
    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo") | out-null
    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.ConnectionInfo") | out-null
    
    # start here
    "{0} : ============================== "
    "{0} : Starting function: Invoke-ArchiveMaintenance" -f $(Get-Date -Format "HH:mm:ss")
    "{0} : Server Name:       {1}" -f $(Get-Date -Format "HH:mm:ss"), $ServerInstance
    "{0} : Database Name:     {1}" -f $(Get-Date -Format "HH:mm:ss"), $Database
    "{0} : ============================== " -f $(Get-Date -Format "HH:mm:ss")
    
    # execute archiving stored procedure
    $sql = "EXEC [Archive].[usp_Mantain_Archive];"
    $MantainArchive = Invoke-Sqlcmd2 -ServerInstance $ServerInstance -Database $Database -Query $sql -Verbose -QueryTimeout 360

    # clear
    $sql = $null
    $MantainArchive = $null
    "{0} : Done" -f $(Get-Date -Format "HH:mm:ss")
    "{0} : ============================== " -f $(Get-Date -Format "HH:mm:ss")
}

Clear-Host
# run this only if the parameters have been passed to the script
# interface implemented to be called from Windows Task Scheduler or similar applications
if (($ServerName -ne '') -and ($DatabaseName -ne '')) {
    Invoke-ArchiveMaintenance -ServerInstance $ServerName -Database $DatabaseName
}
# otherwise, do nothing
