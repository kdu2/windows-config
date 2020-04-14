# Logoff the user after $maxTimeHours hours with warning message at $warnTimeMinutes
# Show popup again after another hour

param(
    $maxTimeHours = 2.5, # hours
    $warnTimeMinutes = 5 # minutes
)

$sleepyTimeSeconds = $maxTimeHours * 60 * 60
$warnTimeSeconds = $warnTimeMinutes * 60
Start-Sleep -Seconds ($sleepyTimeSeconds - $warnTimeSeconds)

Add-Type -AssemblyName PresentationCore,PresentationFramework
$MessageTitle = "Session Logoff"
$MessageIcon = [System.Windows.MessageBoxImage]::Warning

# retry 
#<#
$ButtonType = [System.Windows.MessageBoxButton]::YesNo
$MessageBody = "You have been logged in for $maxTimeHours hours and will be logged off automatically in $warnTimeMinutes minutes. Would you like to continue working?"
$Result = [System.Windows.MessageBox]::Show($MessageBody,$MessageTitle,$ButtonType,$MessageIcon)
while ($Result -ne 'No') {
    Start-Sleep -Seconds 3600
    $maxTimeHours++
    $Result = [System.Windows.MessageBox]::Show($MessageBody,$MessageTitle,$ButtonType,$MessageIcon)
    Start-Sleep -Seconds $warnTimeSeconds
    if ($Result -eq 'No') { logoff.exe }
}
#>

# force
<#
$ButtonType = [System.Windows.MessageBoxButton]::Ok
$MessageBody = "You have been logged in for $maxTimeHours hours and will be logged off automatically in $warnTimeMinutes minutes. Please logoff and login again to continue working."
$Result = [System.Windows.MessageBox]::Show($MessageBody,$MessageTitle,$ButtonType,$MessageIcon)
Start-Sleep -Seconds $warnTimeSeconds
logoff.exe
#>
