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

Remove-Item -Path ".\VDC-VM`'s.csv" -Force -ErrorAction SilentlyContinue

$VMs | Select-Object Name,OS,powerstate,vmhost,Folder | Sort-Object -Property folder,os | Export-Csv -NoTypeInformation -Path ".\VDC-VM`'s.csv"
$onlineVMcount = ($VMs | Where-Object { $_.powerstate -eq "poweredon" }).count
Write-Output "$onlineVMcount/$($VMs.count) VM's online" | Out-Host
