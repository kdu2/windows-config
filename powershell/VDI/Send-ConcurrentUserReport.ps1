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

$sendmailparams = @{
    SMTPServer = "SMTP"
    From = "email"
    To = "email"
    Subject = "Pool Concurrent Session Report"
    Body = "\\server\share\concurrentUserReport-$date.csv"
}
Send-MailMessage @sendmailparams
