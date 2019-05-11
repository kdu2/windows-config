<#
.SYNOPSIS
    This script configures Windows 10 with minimal configuration for VDI.
.DESCRIPTION
    This script configures Windows 10 with minimal configuration for VDI.
    
    // ============== 
    // General Advice 
    // ============== 

    Before finalizing the image perform the following tasks: 
    - Ensure no unwanted startup files by using autoruns.exe from SysInternals 
    - Run the Disk Cleanup tool as administrator and delete all temporary files and system restore points
    - Run disk defrag and consolidate free space: defrag c: /v /x
    - Reboot the machine 6 times and wait 120 seconds after logging on before performing the next reboot (boot prefetch training)
    - Run disk defrag and optimize boot files: defrag c: /v /b
    - If using a dynamic virtual disk, use the vendor's utilities to perform a "shrink" operation

    // ************* 
    // *  CAUTION  * 
    // ************* 

    THIS SCRIPT MAKES CONSIDERABLE CHANGES TO THE DEFAULT CONFIGURATION OF WINDOWS.

    Please review this script THOROUGHLY before applying to your virtual machine, and disable changes below as necessary to suit your current
    environment.

    This script is provided AS-IS - usage of this source assumes that you are at the very least familiar with PowerShell, and the tools used
    to create and debug this script.

    In other words, if you break it, you get to keep the pieces.
.PARAMETER NoWarn
    Removes the warning prompts at the beginning and end of the script - do this only when you're sure everything works properly!
.EXAMPLE
    .\ConfigWin10asVDI.ps1 -NoWarn $true
.NOTES
    Source:                          https://github.com/cluberti/VDI/blob/master/ConfigAsVDI.ps1
    Original Author:                 Carl Luberti/cluberti
    CCCD version managed by:         Kevin Du/kdu2
    Last Update:                     2019-05-08
    Version:                         2.0
.LOG
    1.0.1 - modified sc command to sc.exe to prevent PS from invoking set-content
    1.0.2 - modified Universal Application section to avoid issues with CopyProfile, updated onedrive removal, updated for TH2
    1.0.3 - modified services and settings to fit CCCD VDI image
    1.0.4 - added to registry: disable Security Center notifications
    1.0.5 - added to registry: configure default user settings
    2.0.0 - updated for LTSC 1809
#>

# Parse Params:
[CmdletBinding()]
Param(
    [Parameter(
        Position=0,
        Mandatory=$False,
        HelpMessage="True or False, do you want to see the warning prompts"
        )] 
        [bool] $NoWarn = $False
)

# Throw caution (to the wind?) - show if NoWarn param is not passed, or passed as $false:
If ($NoWarn -eq $False) {
    Write-Host "THIS SCRIPT MAKES CONSIDERABLE CHANGES TO THE DEFAULT CONFIGURATION OF WINDOWS." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Please review this script THOROUGHLY before applying to your virtual machine, and disable changes below as necessary to suit your current environment." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "This script is provided AS-IS - usage of this source assumes that you are at the very least familiar with PowerShell, and the tools used to create and debug this script." -ForegroundColor Yellow
    Write-Host ""
    Write-Host ""
    Write-Host "In other words, if you break it, you get to keep the pieces." -ForegroundColor Magenta
    Write-Host ""
    Write-Host ""
}

$ProgressPreference = "SilentlyContinue"
$ErrorActionPreference = "SilentlyContinue"

$services = @(
    "AJRouter"
    "ALG"
    "BDESVC"
    "Browser"
    "BthHFSrv"
    "bthserv"
    "CscService"
    "defragsvc"
    "diagnosticshub.standardcollector.service"
    "DiagTrack"
    "DPS"
    "EFS"
    "Fax"
    "fdPHost"
    "FDResPub"
    "fhsvc"
    "HomeGroupListener"
    "HomeGroupProvider"
    "icssvc"
    "lfsvc"
    "MapsBroker"
    "MSiSCSI"
    "NetTcpPortSharing"
    "PeerDistSvc"
    "RetailDemo"
    "SensorDataService"
    "SensorService"
    "SensrSvc"
    "SharedAccess"
    "SSDPSRV"
    "SstpSvc"
    "svsvc"
    "swprv"
    "TabletInputService"
    "TrkWks"
    "UI0Detect"
    "upnphost"
    "VSS"
    "wbengine"
    "WbioSrvc"
    "wcncsvc"
    "WdiServiceHost"
    "WdiSystemHost"
    "WerSvc"
    "WiaRpc"
    "WinDefend"
    "WlanSvc"
    "wlidsvc"
    "WMPNetworkSvc"
    "wscsvc"
    "WwanSvc"
    "XblAuthManager"
    "XblGameSave"
    "XboxNetApiSvc"
)

# // ============
# // Begin Config
# // ============

# Set VM to High Perf scheme:
Write-Host "Setting VM to High Performance Power Scheme..." -ForegroundColor Green
Write-Host ""
POWERCFG -SetActive '8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c'


# Disable Services
foreach ($service in $services) {
    Write-Host "Disabling $((Get-Service $service).displayname)..." -ForegroundColor Cyan
    Set-Service $service -StartupType Disabled
}
Write-Host ""

# Set PeerCaching to Disabled
Write-Host "Disabling PeerCaching..." -ForegroundColor Green
reg add hklm\software\microsoft\windows\currentversion\DeliveryOptimization\Config /v DODownloadMode /t REG_DWORD /d 0 /f
Write-Host ""

# Disable show last username
Write-Host "Disabling show last username..." -ForegroundColor Green
reg add hklm\software\microsoft\windows\currentversion\policies\system /v dontdisplaylastusername /t REG_DWORD /d 1 /f
Write-Host ""

# Enable Autotray
Write-Host "Enabling Autotray..." -ForegroundColor Green
reg add hklm\software\microsoft\windows\currentversion\explorer /v EnableAutoTray /t REG_DWORD /d 0 /f
Write-Host ""

# Disable IE First Run Wizard:
Write-Host "Disabling IE First Run Wizard..." -ForegroundColor Green
reg add "hklm\software\policies\microsoft\Internet Explorer\Main" /v DisableFirstRunCustomize /t REG_DWORD /d 1 /f
Write-Host ""

# Disable Action Center
#Write-Host "Disabling Action Center..." -ForegroundColor Green
#reg add hklm\software\policies\microsoft\windows\explorer /v DisableNotificationCenter /t REG_DWORD /d 1 /f
#Write-Host ""

<#
# Disable OneDrive
Write-Host "Disabling OneDrive..." -ForegroundColor Green
reg add hklm\software\policies\microsoft\windows\OneDrive /v DisableFileSyncNGSC /t REG_DWORD /d 1 /f
Write-Host ""
#>

# Disable new app installed notification
Write-Host "Disabling New app installed notification..." -ForegroundColor Cyan
reg add hklm\software\policies\microsoft\windows\explorer /v NoNewAppAlert /t REG_DWORD /d 0 /f
Write-Host ""

# Disable Game DVR
Write-Host "Disabling Game DVR..." -ForegroundColor Green
reg add hklm\software\policies\microsoft\windows\GameDVR /v AllowgameDVR /t REG_DWORD /d 0 /f
Write-Host ""

#<# Disable Timeline
Write-Host "Disabling Timeline..." -ForegroundColor Green
reg add hklm\software\policies\microsoft\windows\system /v EnableActivityFeed /t REG_DWORD /d 0 /f
Write-Host ""
#>

# Configure default user registry hive
Write-Host "Loading default user hive"
reg load "hku\temp" "c:\users\default\ntuser.dat"
# Disable Security Center notifications
Write-Host "Disabling Security Center notifications..." -ForegroundColor Green
reg add "hku\temp\software\microsoft\windows\currentversion\notifications\settings\Windows.SystemToast.SecurityAndMaintenance" /v Enabled /d 0 /t REG_DWORD  /f
# Disable OneDrive Setup
#Write-Host "Disabling OneDrive setup on login..."
#reg delete "hku\temp\software\microsoft\windows\currentversion\run" /v "OneDriveSetup" /f
#reg delete "hkcu\software\microsoft\windows\currentversion\run" /v "OneDriveSetup" /f
# Disable Game Mode
Write-Host "Disabling Game Bar and Game Mode..." -ForegroundColor Green
reg add "hku\temp\software\microsoft\windows\currentversion\GameDVR" /v AppCaptureEnabled /t REG_DWORD /d 0 /f
reg add "hku\temp\system\GameConfigStore" /v GameDVR_Enabled /t REG_DWORD /d 0 /f
reg add "hku\temp\software\microsoft\GameBar" /v AllowAutoGameMode /t REG_DWORD /d 0 /f
reg add "hku\temp\software\microsoft\GameBar" /v AutoGameModeEnabled /t REG_DWORD /d 0 /f
# Hide VMware tools icon
Write-Host "Hide VMware tools icon"
reg add "hku\temp\software\VMware, Inc.\VMware Tools" /v "ShowTray" /d 0 /t REG_DWORD /f
reg add "hklm\software\VMware, Inc.\VMware Tools" /v "ShowTray" /d 0 /t REG_DWORD /f
# Disable lock screen notifications
Write-Host "Disabling lock screen notifications..." -ForegroundColor Green
reg add "hku\temp\software\microsoft\windows\currentversion\Notifications\Settings" /v "NOC_GLOBAL_SETTING_ALLOW_TOASTS_ABOVE_LOCK" /t REG_DWORD /d 0 /f
reg add "hku\temp\software\microsoft\windows\currentversion\Notifications\Settings" /v "NOC_GLOBAL_SETTING_ALLOW_CRITICAL_TOASTS_ABOVE_LOCK" /t REG_DWORD /d 0 /f
# Set feedback frequency to never
Write-Host "Setting feedback frequency to never..." -ForegroundColor Green
reg add "hku\temp\software\microsoft\Siuf\Rules" /v "NumberOfSIUFInPeriod" /t REG_DWORD /d 0 /f
reg add "hku\temp\software\microsoft\Siuf\Rules" /v "PeriodInNanoSeconds" /t REG_DWORD /d 0 /f
# Set Explorer default to This PC instead of Quick Access
Write-Host "Changing default Explorer view to This PC..." -ForegroundColor Green
reg add "hku\temp\software\microsoft\windows\currentversion\explorer\advanced" /v LaunchTo /t REG_DWORD /d 1 /f
# Disable show frequent/recent files/folders in Quick Access
Write-Host "Disabling show recent files/folders in Quick Access..." -ForegroundColor Green
reg add "hku\temp\software\microsoft\windows\currentversion\explorer" /v ShowFrequent /t REG_DWORD /d 0 /f
reg add "hku\temp\software\microsoft\windows\currentversion\explorer" /v ShowRecent /t REG_DWORD /d 0 /f
# Show file extension in explorer
Write-Host "Show file extensions in File Explorer"
reg add "hku\temp\software\microsoft\windows\currentversion\explorer\advanced" /v HideFileExt /d 0 /t REG_DWORD /f
# Show user files shortcut on desktop
Write-Host "Show user folder and This PC on desktop"
reg add "hku\temp\software\microsoft\windows\currentversion\explorer\HideDesktopIcons\NewStartPanel" /v "{59031a47-3f72-44a7-89c5-5595fe6b30ee}" /d 0 /t REG_DWORD /f
reg add "hku\temp\software\microsoft\windows\currentversion\explorer\HideDesktopIcons\ClassicStartMenu" /v "{59031a47-3f72-44a7-89c5-5595fe6b30ee}" /d 0 /t REG_DWORD /f
# Show This PC shortcut on desktop
Write-Host "Show This PC and User folder icons on desktop"
reg add "hku\temp\software\microsoft\windows\currentversion\explorer\HideDesktopIcons\NewStartPanel" /v "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" /d 0 /t REG_DWORD /f
reg add "hku\temp\software\microsoft\windows\currentversion\explorer\HideDesktopIcons\ClassicStartMenu" /v "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" /d 0 /t REG_DWORD /f
# Set taskbar settings
Write-Host "Set taskbar settings: always combine, large icons, hide search and taskview"
reg add "hku\temp\software\microsoft\windows\currentversion\explorer\advanced" /v TaskbarGlomLevel /d 0 /t REG_DWORD /f
reg add "hku\temp\software\microsoft\windows\currentversion\explorer\advanced" /v TaskbarSmallIcons /d 0 /t REG_DWORD /f
reg add "hku\temp\software\microsoft\windows\currentversion\explorer\advanced" /v ShowTaskViewButton /d 0 /t REG_DWORD /f
reg add "hku\temp\software\microsoft\windows\currentversion\explorer\advanced\People" /v PeopleBand /d 0 /t REG_DWORD /f
reg add "hku\temp\software\Microsoft\Windows\CurrentVersion\Search" /v SearchboxTaskbarMode /d 0 /t REG_DWORD /f 
# Disable auto-update and downloads of Store apps
Write-Host "Disable auto-update and download Store apps"
reg add "hku\temp\software\policies\microsoft\WindowsStore" /v AutoDownload /d 2 /t REG_DWORD /f
# Disable Transparency effects
Write-Host "Disable transparency effects"
reg add "hku\temp\software\microsoft\windows\currentversion\themes\personalize" /v EnableTransparency /d 0 /t REG_DWORD /f
reg unload "hku\temp"
Write-Host ""
# Disable 3rd party apps
Write-Host "Disabling 3rd party apps..." -ForegroundColor Green
reg add "hku\temp\software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SystemPaneSuggestionsEnabled /t REG_DWORD /d 0 /f
reg add "hku\temp\software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v PreInstalledAppsEnabled /t REG_DWORD /d 0 /f
reg add "hku\temp\software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v OemPreInstalledAppsEnabled /t REG_DWORD /d 0 /f
reg add "hku\temp\software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v ContentDeliveryAllowed /t REG_DWORD /d 0 /f
reg add "hku\temp\software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v FeatureManagementEnabled /t REG_DWORD /d 0 /f
reg add "hku\temp\software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v PreInstalledAppsEverEnabled /t REG_DWORD /d 0 /f
reg add "hku\temp\software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v RemediationRequired /t REG_DWORD /d 0 /f
reg add "hku\temp\software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SilentInstalledAppsEnabled /t REG_DWORD /d 0 /f
reg add "hku\temp\software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SoftLandingEnabled /t REG_DWORD /d 0 /f
reg add "hku\temp\software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContentEnabled /t REG_DWORD /d 0 /f
reg add "hku\temp\software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338388Enabled" /t REG_DWORD /d 0 /f
reg add "hku\temp\software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.ContentDeliveryManager_cw5n1h2txyewy" /v Disabled /t REG_DWORD /d 1 /f
# Disable Hardware Acceleration for Office 2016
Write-Host "Disable Hardware Acceleration for Office 2016" -ForegroundColor Green
reg add "hku\temp\Software\Microsoft\Office\16.0\Common\Graphics" /v DisableHardwareAcceleration /d 1 /t REG_DWORD /f
reg unload "hku\temp"
Write-Host ""


# Disable Windows Defender
Write-Host "Disabling Windows Defender"
reg add "hklm\software\policies\microsoft\Windows Defender" /v DisableAntiSpyware /d 1 /t REG_DWORD /f
reg delete "hklm\software\microsoft\windows\currentversion\run" /v WindowsDefender /f
Write-Host""

# Disable Cortana:
#Write-Host "Disable Cortana"
#reg add "hklm\software\policies\microsoft\windows\Windows Search" /v AllowCortana /t REG_DWORD /d 0 /f
#Write-Host ""

# Disable Sign-in Animation
Write-Host "Disabling First Sign-in Animation" -ForegroundColor Green
reg add hklm\software\microsoft\windows\currentversion\policies\system /v EnableFirstLogonAnimation /t REG_DWORD /d 0 /f
Write-Host ""

# Disable App Auto-install after 1st login
Write-Host "Disabling App Auto-install after 1st login" -ForegroundColor Cyan
reg add HKLM\Software\Policies\Microsoft\Windows\CloudContent /v DisableWindowsConsumerFeatures /t REG_DWORD /d 1 /f
Write-Host ""

# Disable show recently added in start menu
Write-Host "Disabling show recently added in start menu" -ForegroundColor Cyan
reg add HKLM\Software\Policies\Microsoft\Windows\Explorer /v HideRecentlyAddedApps /t REG_DWORD /d 1 /f
Write-Host ""

# Disable Automatic Windows Update
Write-Host "Disabling automatic Windows Update" -ForegroundColor Cyan
reg add HKLM\software\policies\microsoft\windows\WindowsUpdate\AU /v NoAutoUpdate /t REG_DWORD /d 1 /f
Write-Host ""

# Disable Automatic Microsoft Store App Update
Write-Host "Disabling automatic Microsoft Store app updates" -ForegroundColor Cyan
reg add hklm\software\policies\microsoft\WindowsStore /v AutoDownload /t REG_DWORD /d 2 /f
Write-Host ""

# Disable Logon Wallpaper
Write-Host "Disabling Logon Wallpaper"
reg add hklm\software\policies\microsoft\windows\system /v DisableLogonBackgroundImage /t REG_DWORD /d 1 /f
Write-Host ""

<#
# Reconfigure / Change Services:
Write-Host "Configuring Network List Service to start Automatic..." -ForegroundColor Green
Write-Host ""
Set-Service netprofm -StartupType Automatic
Write-Host ""
#>

<#
Write-Host "Configuring Windows Update Service to run in standalone svchost..." -ForegroundColor Cyan
Write-Host ""
sc.exe config wuauserv type= own
Write-Host ""
#>

# Disable Scheduled Tasks:
Write-Host "Disabling Scheduled Tasks..." -ForegroundColor Cyan
Write-Host ""
Disable-ScheduledTask -TaskName "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" | Out-Null
Disable-ScheduledTask -TaskName "\Microsoft\Windows\Application Experience\ProgramDataUpdater" | Out-Null
Disable-ScheduledTask -TaskName "\Microsoft\Windows\Application Experience\StartupAppTask" | Out-Null
Disable-ScheduledTask -TaskName "\Microsoft\Windows\Autochk\Proxy" | Out-Null
Disable-ScheduledTask -TaskName "\Microsoft\Windows\Bluetooth\UninstallDeviceTask" | Out-Null
Disable-ScheduledTask -TaskName "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator" | Out-Null
Disable-ScheduledTask -TaskName "\Microsoft\Windows\Customer Experience Improvement Program\KernelCeipTask" | Out-Null
Disable-ScheduledTask -TaskName "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip" | Out-Null
Disable-ScheduledTask -TaskName "\Microsoft\Windows\Diagnosis\Scheduled" | Out-Null
Disable-ScheduledTask -TaskName "\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector" | Out-Null
Disable-ScheduledTask -TaskName "\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticResolver" | Out-Null
Disable-ScheduledTask -TaskName "\Microsoft\Windows\Maintenance\WinSAT" | Out-Null
Disable-ScheduledTask -TaskName "\Microsoft\Windows\Maps\MapsToastTask" | Out-Null
Disable-ScheduledTask -TaskName "\Microsoft\Windows\Maps\MapsUpdateTask" | Out-Null
Disable-ScheduledTask -TaskName "\Microsoft\Windows\MemoryDiagnostic\ProcessMemoryDiagnosticEvents" | Out-Null
Disable-ScheduledTask -TaskName "\Microsoft\Windows\MemoryDiagnostic\RunFullMemoryDiagnostic" | Out-Null
Disable-ScheduledTask -TaskName "\Microsoft\Windows\Mobile Broadband Accounts\MNO Metadata Parser" | Out-Null
Disable-ScheduledTask -TaskName "\Microsoft\Windows\Power Efficiency Diagnostics\AnalyzeSystem" | Out-Null
Disable-ScheduledTask -TaskName "\Microsoft\Windows\Ras\MobilityManager" | Out-Null
Disable-ScheduledTask -TaskName "\Microsoft\Windows\Registry\RegIdleBackup" | Out-Null
Disable-ScheduledTask -TaskName "\Microsoft\Windows\RetailDemo\CleanupOfflineContent" | Out-Null
Disable-ScheduledTask -TaskName "\Microsoft\Windows\Shell\FamilySafetyMonitor" | Out-Null
Disable-ScheduledTask -TaskName "\Microsoft\Windows\Shell\FamilySafetyRefresh" | Out-Null
Disable-ScheduledTask -TaskName "\Microsoft\Windows\SystemRestore\SR" | Out-Null
Disable-ScheduledTask -TaskName "\Microsoft\Windows\UPnP\UPnPHostConfig" | Out-Null
Disable-ScheduledTask -TaskName "\Microsoft\Windows\WDI\ResolutionHost" | Out-Null
Disable-ScheduledTask -TaskName "\Microsoft\Windows\Windows Media Sharing\UpdateLibrary" | Out-Null
Disable-ScheduledTask -TaskName "\Microsoft\Windows\WOF\WIM-Hash-Management" | Out-Null
Disable-ScheduledTask -TaskName "\Microsoft\Windows\WOF\WIM-Hash-Validation" | Out-Null

# Disable Hard Disk Timeouts:
Write-Host "Disabling Hard Disk Timeouts..." -ForegroundColor Yellow
Write-Host ""
POWERCFG /SETACVALUEINDEX 381b4222-f694-41f0-9685-ff5bb260df2e 0012ee47-9041-4b5d-9b77-535fba8b1442 6738e2c4-e8a5-4a42-b16a-e040e769756e 0
POWERCFG /SETDCVALUEINDEX 381b4222-f694-41f0-9685-ff5bb260df2e 0012ee47-9041-4b5d-9b77-535fba8b1442 6738e2c4-e8a5-4a42-b16a-e040e769756e 0

# Disable Hibernate
Write-Host "Disabling Hibernate..." -ForegroundColor Green
Write-Host ""
POWERCFG -h off

# Disable Large Send Offload
Write-Host "Disabling TCP Large Send Offload..." -ForegroundColor Green
Write-Host ""
New-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters -Name 'DisableTaskOffload' -PropertyType DWORD -Value '1' | Out-Null

# Disable IPv6
Write-Host "Disabling IPv6..." -ForegroundColor Green
Write-Host ""
New-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters -Name 'DisabledComponents' -PropertyType DWORD -Value '0xffffffff' | Out-Null

# Disable Active Setup components
Write-Host "Disabling Active Setup components..." -ForegroundColor Green
Remove-Item -Path 'HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{2C7339CF-2B09-4501-B3F3-F3508C9228ED}' | Out-Null
Remove-Item -Path 'HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{2D46B6DC-2207-486B-B523-A557E6D54B47}' | Out-Null
Remove-Item -Path 'HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{44BBA840-CC51-11CF-AAFA-00AA00B6015C}' | Out-Null
Remove-Item -Path 'HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{6BF52A52-394A-11d3-B153-00C04F79FAA6}' | Out-Null
Remove-Item -Path 'HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{89820200-ECBD-11cf-8B85-00AA005B4340}' | Out-Null
Remove-Item -Path 'HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{89820200-ECBD-11cf-8B85-00AA005B4383}' | Out-Null
Remove-Item -Path 'HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{89B4C1CD-B018-4511-B0A1-5476DBF70820}' | Out-Null
Remove-Item -Path 'HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\>{22d6f312-b0f6-11d0-94ab-0080c74c7e95}' | Out-Null
Write-Host ""

# Disable System Restore
Write-Host "Disabling System Restore..." -ForegroundColor Green
Write-Host ""
Disable-ComputerRestore -Drive "C:\"

# Disable NTFS Last Access Timestamps
Write-Host "Disabling NTFS Last Access Timestamps..." -ForegroundColor Yellow
Write-Host ""
FSUTIL behavior set disablelastaccess 1 | Out-Null

# Disable Machine Account Password Changes
Write-Host "Disabling Machine Account Password Changes..." -ForegroundColor Yellow
Write-Host ""
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters' -Name 'DisablePasswordChange' -Value '1'

# Disable Memory Dumps
Write-Host "Disabling Memory Dump Creation..." -ForegroundColor Green
Write-Host ""
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl' -Name 'CrashDumpEnabled' -Value '1'
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl' -Name 'LogEvent' -Value '0'
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl' -Name 'SendAlert' -Value '0'
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl' -Name 'AutoReboot' -Value '1'

# Increase Service Startup Timeout:
Write-Host "Increasing Service Startup Timeout To 180 Seconds..." -ForegroundColor Yellow
Write-Host ""
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control' -Name 'ServicesPipeTimeout' -Value '180000'

# Increase Disk I/O Timeout to 200 Seconds:
Write-Host "Increasing Disk I/O Timeout to 200 Seconds..." -ForegroundColor Green
Write-Host ""
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\Disk' -Name 'TimeOutValue' -Value '200'

# Disable New Network Dialog:
Write-Host "Disabling New Network Dialog..." -ForegroundColor Green
Write-Host ""
New-Item -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Network' -Name 'NewNetworkWindowOff' | Out-Null

# Remove Previous Versions:
Write-Host "Removing Previous Versions Capability..." -ForegroundColor Yellow
Write-Host ""
Set-ItemProperty -Path 'HKLM:\SOFTWARE\\Microsoft\Windows\CurrentVersion\Explorer' -Name 'NoPreviousVersionsPage' -Value '1'

# Configure Search Options:
Write-Host "Configuring Search Options..." -ForegroundColor Green
Write-Host ""
New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search' -Name 'AllowSearchToUseLocation' -PropertyType DWORD -Value '0' | Out-Null
New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search' -Name 'ConnectedSearchUseWeb' -PropertyType DWORD -Value '0' | Out-Null
#New-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search' -Name 'SearchboxTaskbarMode' -PropertyType DWORD -Value '1' | Out-Null
Write-Host ""

#<#
# PCoIP and framerate settings
Write-Host "Configuring PCoIP and framerate settings" -ForegroundColor Green
reg add "hklm\software\VMware, Inc.\VMware SVGA DevTap" /v MaxAppFrameRate /t REG_DWORD /d 0 /f
reg add "hklm\software\policies\Teradici\PCoIP\pcoip_admin" /v "pcoip.enable_temporal_image_caching" /t REG_DWORD /d 0 /f
reg add "hklm\software\policies\Teradici\PCoIP\pcoip_admin" /v "pcoip.device_bandwidth_target" /t REG_DWORD /d 0x00008000 /f
Write-Host ""
#>

# Did this break?:
If ($NoWarn -eq $False)
{
    Write-Host "This script has completed." -ForegroundColor Green
    Write-Host ""
    Write-Host "Please review output in your console for any indications of failures, and resolve as necessary." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Remember, this script is provided AS-IS - review the changes made against the expected workload of this VDI VM to validate things work properly in your environment." -ForegroundColor Magenta
    Write-Host ""
    Write-Host "Good luck! (reboot required)" -ForegroundColor White
}
