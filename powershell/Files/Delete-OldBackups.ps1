# delete all except for the 5 most recent backups
param([string]$path)

if ($path -eq $null) { exit 1 }

$backups = Get-ChildItem -Path $path -Directory | Sort-Object -Descending -Property LastWriteTime | Select-Object -Skip 5
foreach ($backup in $backups ) {
    Remove-Item $_ -Force -Recurse
}
