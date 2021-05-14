function Test-Port($HostName, $Port) {
    # This works no matter in which form we get $host - HostName or ip address
    try {
        $ip = [System.Net.Dns]::GetHostAddresses($HostName) | 
            Select-Object IPAddressToString -expandproperty  IPAddressToString
        if ($ip.GetType().Name -eq "Object[]") {
            #If we have several ip's for that address, let's take first one
            $ip = $ip[0]
        }
    } 
    catch {
        # $HostName could be the incorrect HostName or IP Address
        Return $False
    }
    $t = New-Object Net.Sockets.TcpClient
    # We use Try\Catch to remove exception info from console if we can't connect
    try {$t.Connect($ip,$Port)} catch {}

    if($t.Connected) {
        $t.Close()
        Return $True
    }
    else {
        Return $False
    }
}
