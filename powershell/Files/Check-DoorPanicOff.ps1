param(
    [string]$lockfile,
    [string]$unlockfile
)

$locked = Import-Csv $lockfile
$unlocked = Import-Csv $unlockfile

foreach ($lock in $locked) {
    if ($unlocked.device -notcontains $lock.device ) {
        Write-Host "$($lock.device) at $($lock.location) not unlocked"
    }
}
