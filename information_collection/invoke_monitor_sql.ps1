# required when using PSRemoting: 
# Set-Item wsman:\\localhost\Client\TrustedHosts -value *

# Global params
$CurrentPath = $PSScriptRoot
. "$($CurrentPath)\SqlMon_Functions.ps1"

Clear-Host
$ServerInstance = "SQLSRV01"
$Database = "SQLMonitor"
$ProfileName = "Monitor"

#$ProfileType = "Monthly"
#$ProfileType = "Weekly"
$ProfileType = "Manual"

Get-ServerInfo -ServerInstance $ServerInstance -Database $Database -ProfileName $ProfileName -ProfileType $ProfileType

$ProfileType = $null
$ServerInstance = $null
$Database = $null
$ProfileName = $null
