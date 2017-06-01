param([string]$ComputerList,[string]$ExcludedUsers)

Start-Transcript -Path C:\logs\deleteUserAccounts.log

# Get list of users to skip when deleting profiles
$SkippedUsers = Get-Content $ExcludedUsers

# Delete profiles in parallel to speed up run time.
workflow DeleteUserAccounts { parallel { InlineScript { Get-WmiObject -ComputerName $PSComputerName -Class Win32_UserProfile | Where-Object {!$_.Special -and $SkippedUsers -notcontains ($_.LocalPath).Substring(9) } | Remove-WmiObject -Verbose } } }

# Get a reference to all computer names
$computers = Get-Content $ComputerList

# Run our workflow
DeleteUserAccounts -PSComputerName $computers

$skippedusers -notlike
