# delete files older than 6 months

$limit = (Get-Date).AddDays(-180)
$path = "E:\test"

# delete files
Get-ChildItem -Path $path -Exclude "*.ps1" -Recurse -Force | where { !$_.PSIsContainer -and $_.CreationTime -lt $limit } | Remove-Item -Force
# delete empty folders
Get-ChildItem -Path $path -Recurse -Force | where { $_.PSIsContainer -and (Get-ChildItem -Path $_.FullName -Recurse -Force | Where-Object { !$_.PSIsContainer }) -eq $null } | Remove-Item -Force -Recurse
