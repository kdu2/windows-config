$drives = Get-PSDrive | Where-Object { $_.DisplayRoot -like "\\server*" }
if (!$drives) { exit }

$date = Get-Date -Format yyyy-MM-dd
$time = Get-Date -Format HH:mm:ss
$logfile = "\\server\remap`$\drivemappings-$date.csv"
$logentry = @()

foreach ($drive in $drives) {
    $letter = $drive.Name
    $path = $drive.DisplayRoot.Replace('old','new')
    net use /delete "$letter`:"
    net use "$letter`:" $path /persistent:yes
    $logentry += "`"$time`",`"$env:computername`",`"$env:username`",`"$letter`",`"$($drive.displayroot)`""
}

if (!(Test-Path $logfile)) {
    Write-Output "`"time`",`"computer`",`"username`",`"drive`",`"share`"" | Out-File -Append $logfile -Encoding Ascii
}
Write-Output $logentry | Out-File -Append -FilePath $logfile -Encoding Ascii

#Stop-Process -Name explorer
if (!(Get-Process -Name explorer)) { Start-Process explorer }
