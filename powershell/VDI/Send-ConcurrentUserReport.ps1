$date = Get-Date -Format yyyyMMdd
$concurrentUserCounts = Import-csv "\\server\share\sessions-$date.csv"
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
    foreach ($userCount in $concurrentUserCounts) {
        if ($userCount.Name -eq $pool) {
            $num = [int]$userCount.'Sessions'
            if ($num -gt $max) {
                $max = $num
            }
            $sum += $num
            $count++
        }
    }
    $avg = $sum/$count
    $obj = New-Object PSObject
    $obj | Add-Member -MemberType NoteProperty -Name "Name" -Value $pool
    $obj | Add-Member -MemberType NoteProperty -Name "Average Concurrent Users" -Value $avg
    $obj | Add-Member -MemberType NoteProperty -Name "Max Concurrent Users" -Value $max
    $concurrentUserReport += $obj
}

$concurrentUserReport | Export-csv -NoTypeInformation -Path "\\server\share\concurrentUserReport-$date.csv"

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
    Subject = "Pool Concurrent Session Report $subjectdate"
    Body = $concurrentUserReport | Convertto-HTML -Header $css | Out-String
}
Send-MailMessage @sendmailparams -BodyAsHtml
