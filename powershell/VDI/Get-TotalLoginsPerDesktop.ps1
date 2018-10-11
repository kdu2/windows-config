param([string]$logpath=$PSScriptRoot,[string]$outputpath=$PSScriptRoot)

# change these
$logtype = "*.log"
$prefix = "prefix"
$suffix = "suffix"
$desktopmax = 1000

$logs = Get-ChildItem -Path $logpath $logtype

foreach ($day in $logs) {
    $desktops = @()
    for ($i = 1; $i -lt $desktopmax; $i++) {
        $desktop_temp = @()
        $desktop_temp = New-Object System.Object
        $desktopname = "$prefix-$($i)$suffix"
        $logincount = Select-String -InputObject $day -Pattern $desktopname -AllMatches
        $desktop_temp | Add-Member -MemberType NoteProperty -Name Desktop -Value $desktopname
        $desktop_temp | Add-Member -MemberType NoteProperty -Name Logins -Value $logincount.matches.count
        $desktops += $desktop_temp
    }
    $desktops | sort -Descending -Property Logins | Export-Csv -Path "$outputpath\logincount-$($day.basename).csv" -NoTypeInformation
}
