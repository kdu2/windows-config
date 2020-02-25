$winver = Get-ItemPropertyValue 'hklm:\software\microsoft\windows nt\currentversion' -Name ReleaseId

$oldtile = "1703","1709"
$newtile = "1803","1809"

$profiles = Get-ChildItem -Path 'C:\Users' -Directory -Exclude "admin","Default","Public"

foreach ($user in $profiles) {
    if (Test-Path -Path "$($user.fullname)\ntuser.dat") {
        reg.exe load hku\temp "$($user.fullname)\ntuser.dat"
        switch ($winver) {
            { $oldtile -contains $winver } { Remove-Item 'HKU:\temp\Software\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount\$start.tilegrid$windows.data.curatedtilecollection.root' -Force -Recurse }
            { $newtile -contains $winver } { Remove-Item 'HKU:\temp\Software\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount\*$start.tilegrid$windows.data.curatedtilecollection.tilecollection'  -Force -Recurse }
            default {
                Write-Host "Windows $winver not supported"
                exit 1
            }
        }
        reg.exe unload hku\temp
    }
}
