param([string]$computer,[int]$port)

$socket = New-Object system.net.sockets.tcpclient
        
# disable error messages
$ErrorActionPreference = 'SilentlyContinue'

# try to connect
$socket.connect($computer, $port)

# enable error messages
$ErrorActionPreference = 'Continue'

# check if connected
if ($socket.connected) {
    Write-Host "$computer`: Port $port is open"
    $socket.close()
} else {
    Write-Host "$computer`: Port $port is closed or filtered"
}

# reset socket
$socket.Dispose()
$socket = $null
