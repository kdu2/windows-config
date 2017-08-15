
<#
.SYNOPSIS
    This script configures Windows 10 with minimal configuration for base images.
.DESCRIPTION
    This script configures Windows 10 with minimal configuration for base images.
    
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
    .\Config-Win10-CCCD.ps1 -NoWarn $true
.NOTES
    Source:                          https://github.com/cluberti/VDI/blob/master/ConfigAsVDI.ps1
    Original Author:                 Carl Luberti/cluberti
    CCCD version managed by:         Kevin Du/kdu2
    Last Update:                     4-11-2017
    Version:                         1.0.6
.LOG
    1.0.1 - modified sc command to sc.exe to prevent PS from invoking set-content
    1.0.2 - modified Universal Application section to avoid issues with CopyProfile, updated onedrive removal, updated for TH2
    1.0.3 - modified services and various settings to fit non VDI image
    1.0.4 - removed windows update from list to disable, added Redstone apps to remove
    1.0.5 - removed all tasks and some settings, only keep remove apps and some registry settings
    1.0.6 - added to registry section: disable security center notifications
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
    Write-Host "Please review this script THOROUGHLY before applying to your machine, and disable changes below as necessary to suit your current environment." -ForegroundColor Yellow
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

$apps = @(
    # default Windows 10 apps
    "Microsoft.3DBuilder"
    "Microsoft.Appconnector"
    "Microsoft.BingFinance"
    "Microsoft.BingNews"
    "Microsoft.BingSports"
    #"Microsoft.BingWeather"
    "Microsoft.FreshPaint"
    "Microsoft.BingTranslator"
    "Microsoft.Getstarted"
    "Microsoft.MicrosoftOfficeHub"
    "Microsoft.MicrosoftSolitaireCollection"
    #"Microsoft.MicrosoftStickyNotes"
    #"Microsoft.Office.OneNote"
    "Microsoft.OneConnect"
    "Microsoft.People"
    "Microsoft.SkypeApp"
    #"Microsoft.Windows.Photos"
    #"Microsoft.WindowsAlarms"
    #"Microsoft.WindowsCalculator"
    #"Microsoft.WindowsCamera"
    "Microsoft.WindowsMaps"
    "Microsoft.WindowsPhone"
    #"Microsoft.WindowsSoundRecorder"
    #"Microsoft.WindowsStore"
    "Microsoft.XboxApp"
    "Microsoft.ZuneMusic"
    "Microsoft.ZuneVideo"
    "microsoft.windowscommunicationsapps"
    "Microsoft.MinecraftUWP"

    # Threshold 2 apps
    "Microsoft.CommsPhone"
    "Microsoft.ConnectivityStore"
    "Microsoft.Messaging"
    "Microsoft.Office.Sway"
    "Microsoft.WindowsFeedbackHub"

    # Redstone apps
    "Microsoft.BingFoodAndDrink"
    "Microsoft.BingTravel"
    "Microsoft.BingHealthAndFitness"
    "Microsoft.WindowsReadingList"
    "Microsoft.NetworkSpeedTest"
    "Microsoft.RemoteDesktop"
    "Microsoft.MicrosoftPowerBIForWindows"

    # Redstone 2 apps

    # non-Microsoft
    "PandoraMediaInc.29680B314EFC2"
    "4DF9E0F8.Netflix"
    "6Wunderkinder.Wunderlist"
    "Duolingo"
    "46928bounde.EclipseManager"
    "D5EA27B7.Duolingo-LearnLanguagesforFree"
    "Drawboard.DrawboardPDF"
    "2FE3CB00.PicsArt-PhotoStudio"
    "D52A8D61.FarmVille2CountryEscape"
    "TuneIn.TuneInRadio"
    "GAMELOFTSA.Asphalt8Airborne"
    "*.Twitter"
    "Flipboard.Flipboard"
    "ShazamEntertainmentLtd.Shazam"
    "king.com.CandyCrushSaga"
    "king.com.CandyCrushSodaSaga"
    "king.com.*"
    "ClearChannelRadioDigital.iHeartRadio"
    "TheNewYorkTimes.NYTCrossword"
    "AdobeSystemsIncorporated.AdobePhotoshopExpress"
    "ActiproSoftwareLLC.562882FEEB491"

    # apps which cannot be removed using Remove-AppxPackage
    #"Microsoft.BioEnrollment"
    #"Microsoft.MicrosoftEdge"
    #"Microsoft.Windows.Cortana"
    #"Microsoft.WindowsFeedback"
    #"Microsoft.XboxGameCallableUI"
    #"Microsoft.XboxIdentityProvider"
    #"Windows.ContactSupport"
)

$services = @(
    "XblAuthManager"
    "XblGameSave"
    "XboxNetApiSvc"
)

# // ============
# // Begin Config
# // ============

# Remove Apps
foreach ($app in $apps) {
    Write-Host "Trying to remove $app" -ForegroundColor Green
    Get-AppxPackage -Name $app -AllUsers | Remove-AppxPackage
    Get-AppxPackage -Name $app | Remove-AppxPackage
    Get-AppXProvisionedPackage -Online | where DisplayName -EQ $app | Remove-AppxProvisionedPackage -Online
    Write-Host "$app has been removed"
}
Write-Host ""

# Disable Services
foreach ($service in $services) {
    Write-Host "Disabling $((Get-Service $service).displayname)..." -ForegroundColor Cyan
    Set-Service $service -StartupType Disabled
}
Write-Host ""

# Configure registry

# Set PeerCaching to Disabled
Write-Host "Disabling PeerCaching..." -ForegroundColor Green
#Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config' -Name 'DODownloadMode' -Value '0'
reg add hklm\software\microsoft\windows\currentversion\DeliveryOptimization\Config /v DODownloadMode /t REG_DWORD /d 0 /f
Write-Host ""

# Disable show last username
#Write-Host "Disabling show last username..." -ForegroundColor Green
#reg add hklm\software\microsoft\windows\currentversion\policies\system /v dontdisplaylastusername /t REG_DWORD /d 1 /f
#Write-Host ""

# Disable IPv6
Write-Host "Disabling IPv6..." -ForegroundColor Green
reg add hklm\system\currentcontrolset\services\tcpip\parameters /v DisabledComponents /t REG_DWORD /d 0xffffffff /f
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

# Disable OneDrive
#Write-Host "Disabling OneDrive..." -ForegroundColor Green
#reg add hklm\software\policies\microsoft\windows\OneDrive /v DisableFileSyncNGSC /t REG_DWORD /d 1 /f
#Write-Host ""

# Configure default user registry hive
reg load "hku\temp" "c:\users\default\ntuser.dat"
# Disable Security Center notifications
Write-Host "Disabling Security Center notifications..." -ForegroundColor Green
reg add "hku\temp\software\microsoft\windows\currentversion\notifications\settings\Windows.SystemToast.SecurityAndMaintenance" /v Enabled /d 0 /t REG_DWORD  /f
reg add "hkcu\software\microsoft\windows\currentversion\notifications\settings\Windows.SystemToast.SecurityAndMaintenance" /v Enabled /d 0 /t REG_DWORD  /f
# Disable OneDrive Setup
reg delete "hku\temp\software\microsoft\windows\currentversion\run" /v "OneDriveSetup" /f
reg delete "hkcu\software\microsoft\windows\currentversion\run" /v "OneDriveSetup" /f
# Show file extension in explorer
reg add "hku\temp\software\microsoft\windows\currentversion\explorer\advanced" /v HideFileExt /d 0 /t REG_DWORD /f
# Show user files shortcut on desktop
reg add "hku\temp\software\microsoft\windows\currentversion\explorer\HideDesktopIcons\NewStartPanel" /v "{59031a47-3f72-44a7-89c5-5595fe6b30ee}" /d /t REG_DWORD /f
reg add "hku\temp\software\microsoft\windows\currentversion\explorer\HideDesktopIcons\ClassicStartMenu" /v "{59031a47-3f72-44a7-89c5-5595fe6b30ee}" /d /t REG_DWORD /f
# Show This PC shortcut on desktop
reg add "hku\temp\software\microsoft\windows\currentversion\explorer\HideDesktopIcons\NewStartPanel" /v "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" /d 0 /t REG_DWORD /f
reg add "hku\temp\software\microsoft\windows\currentversion\explorer\HideDesktopIcons\ClassicStartMenu" /v "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" /d 0 /t REG_DWORD /f
# Set taskbar settings
reg add "hku\temp\software\microsoft\windows\currentversion\explorer\advanced" /v TaskbarGlomLevel /d 0 /t REG_DWORD /f
reg add "hku\temp\software\microsoft\windows\currentversion\explorer\advanced" /v TaskbarSmallIcons /d 0 /t REG_DWORD /f
reg add "hku\temp\software\microsoft\windows\currentversion\explorer\advanced" /v ShowTaskViewButton /d 0 /t REG_DWORD /f
reg add "hku\temp\software\Microsoft\Windows\CurrentVersion\Search" /v SearchboxTaskbarMode /d 0 /t REG_DWORD /f 
reg unload "hku\temp"
Write-Host ""

# Disable Cortana:
Write-Host "Disabling Cortana..." -ForegroundColor Green
reg add "hklm\software\policies\microsoft\windows\Windows Search" /v AllowCortana /t REG_DWORD /d 0 /f
Write-Host ""

# Disable Sign-in Animation
Write-Host "Disabling First Sign-in Animation" -ForegroundColor Green
reg add hklm\software\microsoft\windows\currentversion\policies\system /v EnableFirstLogonAnimation /t REG_DWORD /d 0 /f
Write-Host ""

# Disable App Auto-install after 1st login
Write-Host "Disabling App Auto-install after 1st login" -ForegroundColor Green
reg add HKLM\Software\Policies\Microsoft\Windows\CloudContent /v DisableWindowsConsumerFeatures /t REG_DWORD /d 1 /f
Write-Host ""

# Disable New Network Dialog
Write-Host "Disabling New Network Dialog" -ForegroundColor Green
reg add hklm\system\currentcontrolset\control\network\NewNetworkWindowOff
Write-Host ""

# Enable RDP
Write-Host "Enabling RDP" -ForegroundColor Green
reg add "hklm\system\currentcontrolset\control\terminal server" /v fDenyTSConnections /t REG_DWORD /d 0 /f
Write-Host ""

# Did this break?:
If ($NoWarn -eq $False)
{
    Write-Host "This script has completed." -ForegroundColor Green
    Write-Host ""
    Write-Host "Please review output in your console for any indications of failures, and resolve as necessary." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Remember, this script is provided AS-IS - review the changes made against the expected workload of this desktop to validate things work properly in your environment." -ForegroundColor Magenta
    Write-Host ""
    Write-Host "Good luck! (reboot required)" -ForegroundColor White
}