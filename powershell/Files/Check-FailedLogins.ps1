param([string]$csv,[string]$list)

$accounts = Get-Content $list

$failed_logins = Import-Csv $csv

$account_failed_logins = @()

foreach ($login_attempt in $failed_logins) {
    if ($accounts -contains $login_attempt.'user name') {
        $obj = New-Object PSObject -Property @{
            "username" =         $login_attempt.'user name'
            "IPAddress" =        $login_attempt.'Client IP Address'
            "Hostname" =         $login_attempt.'Client Host Name'
            "DomainController" = $login_attempt.'Domain Controller'
            "LogonTime" =        $login_attempt.'Logon Time'
            "EventType" =        $login_attempt.'Event Type Text'
            "FailureReason" =    $login_attempt.'Failure Reason'
            "Domain" =           $login_attempt.Domain
        }
        $account_failed_logins += $obj
    }
}

$account_failed_logins | ConvertTo-Csv -NoTypeInformation | Out-File -FilePath c:\temp\failed_account_logins.csv -Encoding Ascii
