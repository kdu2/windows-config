param([string]$ConnectionServer)

if ($null -ne $ConnectionServer) {
    Import-Module vmware.hv.helper
    Connect-HVServer -Server $ConnectionServer -User "DOMAIN\USER" -Password "PASSWORD"
    $pools = (Get-HVPoolSummary).DesktopSummaryData | Where-Object { $_.name -notmatch "test|test2" }
    $date = Get-Date -Format yyyyMMdd
    $time = Get-Date -Format hhmm
    $PoolList = @()
    foreach ($pool in $pools) {
        $obj = New-Object PSObject -Property @{
            "Desktop Pool" = $pool.Name
            "Sessions" = $pool.NumSessions
            "Time" = $time
        }
        $PoolList += $obj
    }
    $PoolList | Select-Object Time,Name,Sessions | Export-Csv -NoTypeInformation -Append -Path "\\server\share\sessions-$date.csv"
} else {
    Write-Host "`$ConnectionServer is blank. Please re-run script with valid parameter."
}
