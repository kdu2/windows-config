# delete all except for the 5 most recent backups
param(
    [Parameter(Mandatory=$true)]
    [string]$path
)

$backups = Get-ChildItem -Path "$path" -Directory | Sort-Object -Descending -Property LastWriteTime | Select-Object -Skip 5
foreach ($backup in $backups ) {
    Remove-Item $_ -Force -Recurse
}
