$date = Get-Date -Format yyyyMMdd

$pools = @()
$UserWeeklyReport = @()

$reports = Get-ChildItem -Path "\\server\share" -Filter "UserDailyReport*" | Sort-Object -Property LastWriteTime | Select-Object -Last 7
$today_report = Import-Csv -Path $reports[0].FullName
foreach ($pool in $today_report) {
    $pools += $pool."Desktop Pool"
}

foreach ($pool in $pools) {
    $max_sessions_count = 0
    $max_sessions_day = (Get-Date).DayOfWeek
    $max_sessions_date = Get-Date -Format MM-dd-yyyy
    $max_logins_count = 0
    $max_logins_day = (Get-Date).DayOfWeek
    $max_logins_date = Get-Date -Format MM-dd-yyyy
    $total_logins = 0
    foreach ($report in $reports) {
        $file_date = @{
            Year = $report.name.trimstart("UserDailyReport-").trimend(".csv").substring(0,4)
            Month = $report.name.trimstart("UserDailyReport-").trimend(".csv").substring(4,2)
            Day = $report.name.trimstart("UserDailyReport-").trimend(".csv").substring(6,2)
        }
        $current_day = (Get-Date @file_date).DayOfWeek
        $current_date = (Get-Date @file_date -Format MM-dd-yyyy)
        $current_report = Import-Csv $($report.FullName) | Where-Object { $_."Desktop Pool" -eq $pool }
        if ($max_sessions_count -lt $current_report.'Max Concurrent Users' ) {
            $max_sessions_count = $current_report.'Max Concurrent Users'
            $max_sessions_day = $current_day
            $max_sessions_date = $current_date
        }
        if ($max_logins_count -lt $current_report.'Total Logins') {
            $max_logins_count = $current_report.'Total Logins'
            $max_logins_day = $current_day
            $max_logins_date = $current_date
        }
        $total_logins += $current_report.'Total Logins'
    }
    $obj = New-Object PSObject -Property @{
        "Desktop Pool" = $pool
        "Max Concurrent Users Day" = $max_sessions_day
        "Max Concurrent Date" = $max_sessions_date
        "Max Concurrent Sessions" = $max_sessions_count
        "Max Logins Day" = $max_logins_day
        "Max Logins Date" = $max_logins_date
        "Max Logins Count" = $max_logins_count
        "Total Logins" = $total_logins
    }
    $UserWeeklyReport += $obj
}

$UserWeeklyReport_final = $UserWeeklyReport | Sort-Object "Desktop Pool" | Select-Object "Desktop Pool","Max Concurrent Users Day","Max Concurrent Date","Max Concurrent Sessions","Max Logins Day","Max Logins Date","Max Logins Count","Total Logins"
$UserWeeklyReport_final | Export-Csv -NoTypeInformation -Path "\\server\share\logs\sessions\UserWeeklyReport-$date.csv"

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
    Subject = "Pool Weekly Report $subjectdate"
    Body = $UserWeeklyReport_final | Convertto-HTML -Head $css | Out-String
}
Send-MailMessage @sendmailparams -BodyAsHtml
