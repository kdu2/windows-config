$wshell = New-Object -ComObject wscript.shell
while ($true) {
    $wshell.SendKeys("{F15}")
    Start-Sleep -Seconds 5
}
