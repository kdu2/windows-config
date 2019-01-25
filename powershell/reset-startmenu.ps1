$ExistingUserProfiles = Get-WmiObject win32_userprofile | Where-Object -Property "Special" -eq $False | Select-Object -expandProperty SID |
    foreach { ([System.Security.Principal.SecurityIdentifier]("$_")).Translate([System.Security.Principal.NTAccount]).Value } |
    foreach { $_.split("\")[1] }

foreach ($User in $ExistingUserProfiles) {
    reg load "HKU\$User" C:\Users\$User\NTUSER.DAT
    reg delete "HKU\$User\Software\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount" /f
    reg unload "HKU\$User"
    Copy-Item -Path "$PSScriptRoot\start.xml" "C:\users\$User\Appdata\Local\Microsoft\Windows\Shell\LayoutModification.xml" -Force
}

Stop-Process -ProcessName Explorer -Force
