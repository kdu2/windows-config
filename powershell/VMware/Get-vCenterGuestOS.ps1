param([Parameter(Mandatory=$true)][string]$vcenterserver)

if (!(Get-Module "vmware.vimautomation.core")) {
    Import-Module "vmware.vimautomation.core"
}

Connect-VIServer $vcenterserver

$desktopIDs = "windows7_64Guest",
"windows7Guest",
"windows8_64Guest",
"windows8Guest",
"windows9_64Guest",
"windows9Guest",
"winLonghorn64Guest",
"winLonghornGuest",
"winVista64Guest",
"winVistaGuest",
"winXPPro64Guest",
"winXPProGuest",
"winXPHomeGuest"

$VMs = Get-VM | Where-Object { $desktopIDs -notcontains $_.guestid }
foreach ($vm in $VMs) {
    if ($vm.guest.osfullname -ne $null) {
        $vm | Add-Member -MemberType NoteProperty -Name OS -Value $vm.guest.osfullname
    } else {
        $vm | Add-Member -MemberType NoteProperty -Name OS -Value $vm.guestid
    }
}
Add-Content -Path ".\VDC-VM`'s.csv" -Value "sep=," -Force

$VMs | Select-Object Name,OS,vmhost,Folder | Sort-Object -Property folder,os | ConvertTo-Csv -NoTypeInformation | Out-File -FilePath ".\VDC-VM`'s.csv" -Append
Write-Output "Total VMs: $($VMs.count)" | Out-Host
