$date = Get-Date -Format yyyyMMdd
$clientdate = Get-Date -Format yyyy-MM-dd
$concurrentUserCounts = Import-csv "\\server\share\sessions-$date.csv"
$clientLogins = Import-Csv "\\server\share\clients-$clientdate.csv"
$pools = @()
$concurrentUserReport = @()

foreach ($userCount in $concurrentUserCounts) {
    $pools += $userCount.Name
}

$pools = $pools | Select-Object -Unique

foreach ($pool in $pools) {
    $max = 0
    $avg = 0
    $count = 0
    $sum = 0
    $logins = 0
    foreach ($userCount in $concurrentUserCounts) {
        if ($userCount."Desktop Pool" -eq $pool) {
            $num = [int]$userCount.'Sessions'
            if ($num -gt $max) {
                $max = $num
            }
            $sum += $num
            $count++
        }
    }
    $logins = ($clientLogins | Where-Object { $_."Desktop Pool" -eq $pool }).count
    $avg = $sum/$count
    $obj = New-Object PSObject -Property @{
        "Desktop Pool" = $pool
        "Average Concurrent Users" = $avg
        "Max Concurrent Users" = $max
        "Total Logins" = $logins
    }
    $concurrentUserReport += $obj
}

$DailyUserReport_final = $DailyUserReport | Sort-Object -Property "Desktop Pool" | Select-Object "Desktop Pool","Average Concurrent Users","Max Concurrent Users","Total Logins"
$DailyUserReport_final | Export-csv -NoTypeInformation -Path "\\server\share\UserDailyReport-$date.csv"

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
    SMTPServer = "SMTP"
    From = "email"
    To = "email"
    Subject = "Pool Session Report $subjectdate"
    Body = $DailyUserReport_final | Convertto-HTML -Header $css | Out-String
}
Send-MailMessage @sendmailparams -BodyAsHtml
