$date = Get-Date -Format yyyyMMdd

$pools = @()
$concurrentUserWeeklyReport = @()

$reports = Get-ChildItem -Path "\\server\share" -Filter "concurrentUserReport*" | Sort-Object -Property LastWriteTime | Select-Object -Last 6
$today_report = Import-Csv -Path $reports[0].FullName
foreach ($pool in $today_report) {
    $pools += $pool.Name
}

foreach ($pool in $pools) {
    $max = 0
    $day = (Get-Date).DayOfWeek
    $max_date = Get-Date -Format MM-dd-yyyy
    foreach ($report in $reports) {
        $file_date = @{
            Year = $report.name.trimstart("concurrentUserReport-").trimend(".csv").substring(0,4)
            Month = $report.name.trimstart("concurrentUserReport-").trimend(".csv").substring(4,2)
            Day = $report.name.trimstart("concurrentUserReport-").trimend(".csv").substring(6,2)
        }
        $current_day = (Get-Date @file_date).DayOfWeek
        $current_date = (Get-Date @file_date -Format MM-dd-yyyy)
        $current_report = Import-Csv $($report.FullName) | Where-Object { $_.Name -eq $pool }
        if ($max -lt $current_report.'Max Concurrent Users' ) {
            $max = $current_report.'Max Concurrent Users'
            $day = $current_day
            $max_date = $current_date
        }
    }
    $obj = New-Object PSObject
    $obj | Add-Member -MemberType NoteProperty -Name "Name" -Value $pool
    $obj | Add-Member -MemberType NoteProperty -Name "Day" -Value $day
    $obj | Add-Member -MemberType NoteProperty -Name "Date" -Value $max_date
    $obj | Add-Member -MemberType NoteProperty -Name "Max Concurrent Users" -Value $max
    $concurrentUserWeeklyReport += $obj
}

$concurrentUserWeeklyReport | Export-Csv -NoTypeInformation -Path "\\server\share\concurrentUserWeeklyReport-$date.csv"

$css = @"
<style>
BODY{font-family: Arial; font-size: 10pt; }
TABLE{border: 1px solid black; border-collapse: collapse; }
TH{border: 1px solid black; background: #dddddd; padding: 5px; }
TD{border: 1px solid black; padding: 5px; }
</style>
"@

$subjectdate = Get-Date -Format MM-dd-yyyy

$sendmailparams = @{
    SMTPServer = "SERVER"
    From = "EMAIL"
    To = "EMAIL"
    Subject = "Pool Concurrent Session Weekly Report $subjectdate"
    Body = $concurrentUserReport | Convertto-HTML -Head $css | Out-String
}
Send-MailMessage @sendmailparams -BodyAsHtml
