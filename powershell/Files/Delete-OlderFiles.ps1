# delete files older than 3 months
param(
    [datetime]$limit=(Get-Date).AddDays(-90),
    [Parameter(Mandatory=$true)]
    [string]$path
)

# delete files
Get-ChildItem -Path "$path" -File -Exclude "*.ps1" -Recurse | Where-Object { $_.CreationTime -lt $limit } | ForEach-Object { Write-Host "deleting $($_.name)"; Remove-Item $_ -Force }

# delete empty folders
Get-ChildItem -Path "$path" -Directory -Recurse | Where-Object { (Get-ChildItem -Path $_.FullName -Recurse -File) -eq $null } | ForEach-Object { Write-Host "deleting $($_.name)"; Remove-Item $_ -Force -Recurse }
