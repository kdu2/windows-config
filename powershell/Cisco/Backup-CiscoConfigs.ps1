Import-Module posh-ssh

# Replace values with your own
$TFTPServer = "server"
$Path = "path" # where to save backups
$Username = "username" # ssh user

$date = Get-Date -Format "yyyyMMdd-HHmm"
# create encrypted string file
#"password" | ConvertTo-SecureString -AsPlainText -Force| ConvertFrom-SecureString -Key (1..32) | Out-File $Path\pw.txt
$pwfile = "$Path\pw.txt" # encrypted secure string with key 1..32 (change if needed)
$cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Username, (Get-Content $pwfile | ConvertTo-SecureString -Key (1..32))

$switches = Import-Csv -Path "$Path\switches.csv"

$TimeStart = Get-Date -Format 'HH:mm:ss'
Write-Output "Starting backups at $TimeStart" | Out-File "$Path\backup.log"
foreach ($switch in $switches) {
    # create folder if it doesn't exist
    if (!(Test-Path -PathType Container "$Path\$($switch.name)")) {
        New-Item "$Path\$($switch.name)" -ItemType Directory
    }
    # start the SSH Session
    New-SSHSession -ComputerName $switch.ip -Credential $cred -AcceptKey:$true
    $session = Get-SSHSession | Where-Object { $_.Host -eq $switch.ip }
    # create shell stream
    $stream = $session.Session.CreateShellStream("dumb", 0, 0, 0, 0, 1000)
    # copy running-config and wait before you issue the next command
    $stream.Write("copy running-config tftp`n")
    $stream.Write("$TFTPServer`n")
    $stream.Write("configs/$($switch.name)/$($switch.name)_$date.txt`n") # change path if needed, parent folder named configs
    Start-Sleep -Seconds 3
    # disconnect from host
    $session | Remove-SSHSession
}

$TimeEnd = Get-Date -Format 'HH:mm:ss'
Write-Output "Backups completed at $TimeEnd" | Out-File -Append "$Path\backup.log"

# cleanup configs older than 30 days
Get-ChildItem -Path $Path -File -Filter "*txt" -Exclude "pw.txt" -Recurse | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-30) } | Remove-Item
