# delete files older than 6 months
param([datetime]$limit=(Get-Date).AddDays(-180),[string]$path)

if ($path -eq $null) { exit 1 }

if (!(Get-Module -Name PoshRSJob)) { Import-Module -Name PoshRSJob }

$date = Get-Date -Format yyyyMMdd

# delete files
$files = Get-ChildItem -Path $path -File -Exclude "*.ps1" -Recurse | Where-Object { $_.LastWriteTime -lt $limit }
$files | Start-RSJob -Throttle 2 -ScriptBlock {
    $output = "deleting $($_.name)"
    Write-Host $output
    Write-Output $output | Out-File -Append -Filepath ".\cleanup-$date.log"
    Remove-Item $_ -Force
} | Wait-RSJob -ShowProgress
Get-RSJob | Remove-RSJob

# delete empty folders
$folders = Get-ChildItem -Path $path -Directory -Recurse | Where-Object { (Get-ChildItem -Path $_.FullName -Recurse -File) -eq $null }
$folders | Start-RSJob -Throttle 2 -ScriptBlock {
    $output = "deleting $($_.name)"
    Write-Host $output
    Write-Output $output | Out-File -Append -Filepath ".\cleanup-$date.log"
    Remove-Item $_ -Force
} | Wait-RSJob -ShowProgress
Get-RSJob | Remove-RSJob
