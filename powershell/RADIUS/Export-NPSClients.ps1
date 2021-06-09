$filter = @{ 
    LogName = "Security"
    ID = 6272
    StartTime = [DateTime]::Today.AddDays(-4)
}

$events = Get-WinEvent -FilterHashtable $filter -ErrorAction Stop
$details = $events | select @{label='User'; Expression={$_.properties[1].value}}, @{label='MAC'; Expression={$_.properties[8].value}}

$details | Export-Csv "nps-data.csv"