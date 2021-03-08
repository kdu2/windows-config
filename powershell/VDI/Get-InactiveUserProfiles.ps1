param($profilepath)

$profilelist = Get-ChildItem $profilepath -Directory

$archiveage = Get-Date -Date 01-01-2020

$date = Get-Date -Format yyyyMMdd

if (Test-Path ".\archive_profiles_$date.txt") { Remove-Item ".\archive_profiles_$date.txt" }

foreach ($userprofile in $profilelist) {
    if (!(Test-Path "$($userprofile.fullname)\portability")) { continue }
    $profileage = (Get-Item "$($userprofile.fullname)\portability").lastwritetime
    if ($profileage -le $archiveage) {
        Write-Host $userprofile.name
        Write-Output $userprofile.name | Out-File -Append ".\archive_profiles_$date.txt"
    }
}
