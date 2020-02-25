# This script configures Windows Server with minimal configuration for templates.

$ProgressPreference = "SilentlyContinue"
$ErrorActionPreference = "SilentlyContinue"

# Configure registry

# Set PeerCaching to Disabled
Write-Host "Disabling PeerCaching..." -ForegroundColor Green
#Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config' -Name 'DODownloadMode' -Value '0'
reg add hklm\software\microsoft\windows\currentversion\DeliveryOptimization\Config /v DODownloadMode /t REG_DWORD /d 0 /f
Write-Host ""

# Disable show last username
Write-Host "Disabling show last username..." -ForegroundColor Green
reg add hklm\software\microsoft\windows\currentversion\policies\system /v dontdisplaylastusername /t REG_DWORD /d 1 /f
Write-Host ""

# Disable Automatic Windows Update
Write-Host "Disabling automatic Windows Update" -ForegroundColor Cyan
reg add HKLM\software\microsoft\windows\WindowsUpdate\AU /v NoAutoUpdate /t REG_DWORD /d 1 /f
Write-Host ""

# Disable IE First Run Wizard:
Write-Host "Disabling IE First Run Wizard..." -ForegroundColor Green
reg add "hklm\software\policies\microsoft\Internet Explorer\Main" /v DisableFirstRunCustomize /t REG_DWORD /d 1 /f
Write-Host ""

# Configure default user registry hive
reg load "hku\temp" "c:\users\default\ntuser.dat"
# Disable opening Server Manager at login
Write-Host "Disabling Server Manager launch at login"
reg add "hku\temp\software\microsoft\ServerManager" /v "DoNotOpenServerManagerAtLogon" /t REG_DWORD /d 1 /f
# Set Explorer default to This PC instead of Quick Access
Write-Host "Changing default Explorer view to This PC..." -ForegroundColor Green
reg add "hku\temp\software\microsoft\windows\currentversion\explorer\advanced" /v LaunchTo /t REG_DWORD /d 1 /f
# Disable show frequent/recent files/folders in Quick Access
Write-Host "Disabling show recent files/folders in Quick Access..." -ForegroundColor Green
reg add "hku\temp\software\microsoft\windows\currentversion\explorer" /v ShowFrequent /t REG_DWORD /d 0 /f
reg add "hku\temp\software\microsoft\windows\currentversion\explorer" /v ShowRecent /t REG_DWORD /d 0 /f
# Show file extension in explorer
Write-Host "Enabling show file extension in explorer..." -ForegroundColor Green
reg add "hku\temp\software\microsoft\windows\currentversion\explorer\advanced" /v HideFileExt /d 0 /t REG_DWORD /f
# Show user files shortcut on desktop
Write-Host "Enable show user file icons on desktop..." -ForegroundColor Green
reg add "hku\temp\software\microsoft\windows\currentversion\explorer\HideDesktopIcons\NewStartPanel" /v "{59031a47-3f72-44a7-89c5-5595fe6b30ee}" /d 0  /t REG_DWORD /f
reg add "hku\temp\software\microsoft\windows\currentversion\explorer\HideDesktopIcons\ClassicStartMenu" /v "{59031a47-3f72-44a7-89c5-5595fe6b30ee}" /d 0 /t REG_DWORD /f
# Show This PC shortcut on desktop
Write-Host "Enable show This PC icon on desktop" -ForegroundColor Green
reg add "hku\temp\software\microsoft\windows\currentversion\explorer\HideDesktopIcons\NewStartPanel" /v "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" /d 0 /t REG_DWORD /f
reg add "hku\temp\software\microsoft\windows\currentversion\explorer\HideDesktopIcons\ClassicStartMenu" /v "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" /d 0 /t REG_DWORD /f
# set control panel icon view and size
Write-Host "Set Control Panel icon view and size"
reg add "hku\temp\software\microsoft\windows\currentversion\explorer\ControlPanel" /v StartupPage /t REG_DWORD /d 1 /f
reg add "hku\temp\software\microsoft\windows\currentversion\explorer\ControlPanel" /v AllItemsIconView /t REG_DWORD /d 1 /f
reg unload "hku\temp"
Write-Host ""

<# Disable New Network Dialog
Write-Host "Disabling New Network Dialog" -ForegroundColor Green
reg add hklm\system\currentcontrolset\control\network\NewNetworkWindowOff
Write-Host ""
#>

# Set power configuration
Write-Host "Disabling Hibernate"
powercfg -h off
Write-Host "Setting monitor timeout"
powercfg -change -monitor-timeout-ac 0
Write-Host "Disabling sleep timeout"
powercfg -change -standby-timeout-ac 0
Write-Host ""

# Enable RDP
Write-Host "Enabling RDP" -ForegroundColor Green
reg add "hklm\system\currentcontrolset\control\terminal server" /v fDenyTSConnections /t REG_DWORD /d 0 /f
Write-Host ""

Write-Host "This script has completed." -ForegroundColor Green
