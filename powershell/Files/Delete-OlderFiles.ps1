# delete files older than 6 months
param([datetime]$limit=(Get-Date).AddDays(-180),[string]$path)

if ($path -eq $null) { exit 1}

# delete files
Get-ChildItem -Path $path -File -Exclude "*.ps1" -Recurse | Where-Object { $_.CreationTime -lt $limit } | foreach { Write-Host "deleting $($_.name)"; Remove-Item $_ -Force }
# delete empty folders
Get-ChildItem -Path $path -Directory -Recurse | Where-Object { (Get-ChildItem -Path $_.FullName -Recurse -File) -eq $null } | foreach ( Write-Host "deleting $($_.name)"; Remove-Item $_ -Force -Recurse }
