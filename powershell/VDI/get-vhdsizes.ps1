param([string]$profileroot="\\server\share")

$vhds = Get-ChildItem -File *.vhd -Recurse -Path $profileroot

foreach ($vhd in $vhds) {
    $user = ($vhd.directoryname -Split '\\')[2]
    Write-Output "Processing $user" | Out-Host
    $vhd | Add-Member -MemberType NoteProperty -Name Size -Value ($vhd.length/1MB)
    $vhd | Add-Member -MemberType NoteProperty -Name User -Value $user
}

$vhds | Select-Object user,name,lastaccesstime,size | ConvertTo-Csv -NoTypeInformation | Out-File -FilePath '.\Profile-VHD-Sizes.csv'
