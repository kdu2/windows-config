# script to get current startup type of all services

# save corresponding displayname and name
$servicestatus = Get-Service | select name,displayname,status | sort displayname

# save startup type
$servicestartup = Get-WmiObject Win32_Service | select name,startmode | sort name

$services = @()

# create new object with startup type corresponding to display name
for ($i = 0; $i < $servicestatus.Length; $i++) {
    for ($j = 0; $j < $servicestartup.Length; $j++) {
        if ($service.name -eq $startup.name) {
            $services
        }
    }
}

Write-Output $services | Export-Csv services.csv

