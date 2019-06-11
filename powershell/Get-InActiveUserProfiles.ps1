param(
    [Parameter(Mandatory=$true)]
    [string]$profilepath
)

$profilelist = Get-ChildItem $profilepath -Directory

# replace age with your own custom number for archive age
$archiveage = (Get-Date).AddDays(-365)

$date = Get-Date -Format yyyyMMdd

foreach ($userprofile in $profilelist) {
    # change to your own custom path to check for profile age
    if (!(Test-Path "$($userprofile.fullname)\Desktop")) { continue }
    $vhdage = (Get-Item "$($userprofile.fullname)\Desktop").lastwritetime
    if ($vhdage -le $archiveage) {
        Write-Host $userprofile.name
        Write-Output $userprofile.name | Out-File -Append ".\archive_profiles_$date.txt"
    }
}
