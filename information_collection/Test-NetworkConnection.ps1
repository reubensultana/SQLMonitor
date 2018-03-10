param([String]$ServerName = '',
	  [String]$DatabaseName = '')

# 
# Usage: 
#     .\Test-NetworkConnection.ps1 -ServerName "Server Name" -DatabaseName "SQL Monitor Database"
#     Will run the function (if all input parameters are present and valid)
#

# Global params
$CurrentPath = Get-Location
. "$($CurrentPath)\Community_Functions.ps1"

#------------------------------------------------------------# 

function Test-Port($hostname, $port) {
    # This works no matter in which form we get $host - hostname or ip address
    try {
        $ip = [System.Net.Dns]::GetHostAddresses($hostname) | 
            Select-Object IPAddressToString -expandproperty  IPAddressToString
        if ($ip.GetType().Name -eq "Object[]") {
            #If we have several ip's for that address, let's take first one
            $ip = $ip[0]
        }
    } 
    catch {
        # $hostname could be the incorrect Hostname or IP Address
        Return $False
    }
    $t = New-Object Net.Sockets.TcpClient
    # We use Try\Catch to remove exception info from console if we can't connect
    try {$t.Connect($ip,$port)} catch {}

    if($t.Connected) {
        $t.Close()
        Return $True
    }
    else {
        Return $False
    }
}

#------------------------------------------------------------# 

function Test-DatabaseConnection($InstanceName) {
    # test authentication
    try {
        $result = Invoke-Sqlcmd2 -ServerInstance $InstanceName -Database master -Query "SELECT @@ServerName AS [ServerName];" -QueryTimeout 10
        # if the connection succeeds...
        Return $True
    }
    catch { 
        # if the connection fails...
        Return $False
    }
}

#------------------------------------------------------------# 

function Test-NetworkConnection() {
    [CmdletBinding()]  
    param(  
    [Parameter(Position=0, Mandatory=$true)] [string]$ServerInstance, 
    [Parameter(Position=1, Mandatory=$true)] [string]$Database
    )  
    
    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo") | out-null
    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.ConnectionInfo") | out-null
    
    # start here
    "{0} : ============================== " -f $(Get-Date -Format "HH:mm:ss")
    "{0} : Starting function: Test-NetworkConnection" -f $(Get-Date -Format "HH:mm:ss")
    "{0} : Server Name:       {1}" -f $(Get-Date -Format "HH:mm:ss"), $ServerInstance
    "{0} : Database Name:     {1}" -f $(Get-Date -Format "HH:mm:ss"), $Database
    "{0} : ============================== " -f $(Get-Date -Format "HH:mm:ss")
    
    # get list of servers
    $sql = "EXEC dbo.uspGetServers;"
    $ServerInstances = Invoke-Sqlcmd2 -ServerInstance $ServerInstance -Database $Database -Query $sql -QueryTimeout 30

    # clear
    $sql = $null

    Foreach ($Server in $ServerInstances) {
        $ServerName = $Server.ServerName
        $TcpPort = $Server.SqlTcpPort
        $InstanceName = "$ServerName,$TcpPort"
        "{0} : Testing {1}" -f $(Get-Date -Format "HH:mm:ss"), $InstanceName

        # test connection
        $TestConnection = Test-Port -hostname $ServerName -port $TcpPort
        if ($TestConnection -eq $true) {
            "{0} : Network access OK" -f $(Get-Date -Format "HH:mm:ss")
            # test database authentication
            $TestAuthentication = Test-DatabaseConnection -InstanceName $InstanceName
            if ($TestAuthentication -eq $true) {
                "{0} : Authentication OK" -f $(Get-Date -Format "HH:mm:ss")
            }
            else { 
                Write-Warning "Could not log on to $ServerName on port $TcpPort"
            }
        }
        else {
            Write-Warning "Network access to $ServerName on port $TcpPort not available"
        }
        "{0} : ------------------------------ " -f $(Get-Date -Format "HH:mm:ss")
    }
}

Clear-Host
# run this only if the parameters have been passed to the script
# interface implemented to be called from Windows Task Scheduler or similar applications
if (($ServerName -ne '') -and ($DatabaseName -ne '')) {
    Test-NetworkConnection -ServerInstance $ServerName -Database $DatabaseName
}
# otherwise, do nothing
