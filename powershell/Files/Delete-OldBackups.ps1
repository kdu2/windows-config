# delete all and keep X most recent backups
param(
    [Parameter(Mandatory=$true)]
    [string]$path,
	[int]$backups=5
)

Get-ChildItem -Path "$path" -Directory | Sort-Object -Descending -Property LastWriteTime | Select-Object -Skip $backups | Foreach-Object { Remove-Item $_ -Force -Recurse }
