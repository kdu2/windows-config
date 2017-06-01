# get all service startup types and save to csv file

# get-service does not retrieve startup type so get-wmiobject is needed to save that value
$displaynamelist = Get-Service * | select DisplayName,Name,StartMode | sort DisplayName 
$servicenamelist = Get-WmiObject Win32_Service | select Name,StartMode | sort Name

# compare each service name and add the startup type to the first list
foreach ($service in $displaynamelist) {
    foreach ($servicename in $servicenamelist) {
        if ($service.Name -eq $servicename.Name) {
            $service.StartMode = $servicename.StartMode
        }
    }
}

# export the finished list to a csv file
$displaynamelist | Export-Csv servicestartuptypes.csv
