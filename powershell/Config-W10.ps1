
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
    "Microsoft.BingWeather"
    #"Microsoft.FreshPaint"
    "Microsoft.Getstarted"
    "Microsoft.BingTranslator"
    "Microsoft.MicrosoftOfficeHub"
    "Microsoft.MicrosoftSolitaireCollection"
    "Microsoft.RemoteDesktop"
    "Microsoft.MicrosoftPowerBIForWindows"
    "Microsoft.MinecraftUWP"
    #"Microsoft.MicrosoftStickyNotes"
    "Microsoft.NetworkSpeedTest"
    #"Microsoft.Office.OneNote"
    "Microsoft.OneConnect"
    "Microsoft.People"
    #"Microsoft.Print3D"
    #"Microsoft.SkypeApp"
    #"Microsoft.Windows.Photos"
    "Microsoft.WindowsAlarms"
    #"Microsoft.WindowsCalculator"
    "Microsoft.WindowsCamera"
    "microsoft.windowscommunicationsapps"
    "Microsoft.WindowsMaps"
    "Microsoft.WindowsPhone"
    #"Microsoft.WindowsSoundRecorder"
    #"Microsoft.WindowsStore"
    "Microsoft.XboxApp"
    "Microsoft.XboxGameOverlay"
    "Microsoft.XboxIdentityProvider"
    "Microsoft.XboxSpeechToTextOverlay"
    #"Microsoft.ZuneMusic"
    #"Microsoft.ZuneVideo"

    # Threshold 2 apps
    "Microsoft.CommsPhone"
    "Microsoft.ConnectivityStore"
    "Microsoft.GetHelp"
    "Microsoft.Messaging"
    "Microsoft.Office.Sway"
    "Microsoft.OneConnect"
    "Microsoft.WindowsFeedbackHub"
    
    # Creator's Update apps
    #"Microsoft.MSPaint"

    # Redstone apps
    "Microsoft.BingFoodAndDrink"
    "Microsoft.BingTravel"
    "Microsoft.BingHealthAndFitness"
    "Microsoft.WindowsReadingList"
    "Microsoft.Whiteboard"

    # non-Microsoft
    "9E2F88E3.Twitter"
    "PandoraMediaInc.29680B314EFC2"
    "Flipboard.Flipboard"
    "ShazamEntertainmentLtd.Shazam"
    "king.com.CandyCrushSaga"
    "king.com.CandyCrushSodaSaga"
    "king.com.*"
    "ClearChannelRadioDigital.iHeartRadio"
    "4DF9E0F8.Netflix"
    "6Wunderkinder.Wunderlist"
    "Drawboard.DrawboardPDF"
    "2FE3CB00.PicsArt-PhotoStudio"
    "D52A8D61.FarmVille2CountryEscape"
    "TuneIn.TuneInRadio"
    "GAMELOFTSA.Asphalt8Airborne"
    "TheNewYorkTimes.NYTCrossword"
    "DB6EA5DB.CyberLinkMediaSuiteEssentials"
    "Facebook.Facebook"
    "flaregamesGmbH.RoyalRevolt2"
    "Playtika.CaesarsSlotsFreeCasino"
    "A278AB0D.MarchofEmpires"
    "KeeperSecurityInc.Keeper"
    "ThumbmunkeysLtd.PhototasticCollage"
    "XINGAG.XING"
    "89006A2E.AutodeskSketchBook"
    "D5EA27B7.Duolingo-LearnLanguagesforFree"
    "46928bounde.EclipseManager"
    "ActiproSoftwareLLC.562882FEEB491"
    "DolbyLaboratories.DolbyAccess"
    "SpotifyAB.SpotifyMusic"
    "A278AB0D.DisneyMagicKingdoms"
    "WinZipComputing.WinZipUniversal"
    "AdobeSystemsIncorporated.AdobePhotoshopExpress"
    #"22094SynapticsIncorporate.AudioControls"
    
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
    Get-AppXProvisionedPackage -Online | Where-Object { $_.displayName -eq $app } | Remove-AppxProvisionedPackage -Online
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

# Disable Automatic Windows Update
Write-Host "Disabling automatic Windows Update" -ForegroundColor Cyan
reg add HKLM\software\microsoft\windows\WindowsUpdate\AU /v NoAutoUpdate /t REG_DWORD /d 1 /f
Write-Host ""

# Disable Automatic Microsoft Store App Update
Write-Host "Disabling automatic Microsoft Store app updates" -ForegroundColor Cyan
reg add hklm\software\policies\microsoft\WindowsStore /v AutoDownload /t REG_DWORD /d 2 /f
Write-Host ""

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

# Disable new app installed notification
Write-Host "Disabling New app installed notification..." -ForegroundColor Cyan
reg add hklm\software\policies\microsoft\windows\explorer /v NoNewAppAlert /t REG_DWORD /d 1 /f
Write-Host ""

# Disable OneDrive
Write-Host "Disabling OneDrive..." -ForegroundColor Green
reg add hklm\software\policies\microsoft\windows\OneDrive /v DisableFileSyncNGSC /t REG_DWORD /d 1 /f
Write-Host ""

# Disable Game DVR
Write-Host "Disabling Game DVR..." -ForegroundColor Green
reg add hklm\software\policies\microsoft\windows\GameDVR /v AllowgameDVR /t REG_DWORD /d 0 /f
Write-Host ""

# Disable automatic restart sign-on 
Write-Host "Disabling automatic restart sign-on..." -ForegroundColor Cyan
reg add hklm\software\microsoft\windows\currentversion\policies\system /v DisableAutomaticRestartSignOn /t REG_DWORD /d 1 /f
Write-Host ""

# Configure default user registry hive
reg load "hku\temp" "c:\users\default\ntuser.dat"
# Disable Security Center notifications
Write-Host "Disabling Security Center notifications..." -ForegroundColor Green
reg add "hku\temp\software\microsoft\windows\currentversion\notifications\settings\Windows.SystemToast.SecurityAndMaintenance" /v Enabled /d 0 /t REG_DWORD  /f
reg add "hkcu\software\microsoft\windows\currentversion\notifications\settings\Windows.SystemToast.SecurityAndMaintenance" /v Enabled /d 0 /t REG_DWORD  /f
# Disable OneDrive Setup
Write-Host "Disabling OneDrive Setup..." -ForegroundColor Green
reg delete "hku\temp\software\microsoft\windows\currentversion\run" /v "OneDriveSetup" /f
# Disable Game Bar and Game Mode
Write-Host "Disabling Game Bar and Game Mode..." -ForegroundColor Green
reg add "hku\temp\software\microsoft\windows\currentversion\GameDVR" /v AppCaptureEnabled /t REG_DWORD /d 0 /f
reg add "hku\temp\system\GameConfigStore" /v GameDVR_Enabled /t REG_DWORD /d 0 /f
reg add "hku\temp\software\microsoft\GameBar" /v AllowAutoGameMode /t REG_DWORD /d 0 /f
reg add "hku\temp\software\microsoft\GameBar" /v AutoGameModeEnabled /t REG_DWORD /d 0 /f
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
# Set taskbar settings
Write-Host "Set taskbar display settings..." -ForegroundColor Green
reg add "hku\temp\software\microsoft\windows\currentversion\explorer\advanced" /v TaskbarGlomLevel /d 0 /t REG_DWORD /f
reg add "hku\temp\software\microsoft\windows\currentversion\explorer\advanced" /v TaskbarSmallIcons /d 0 /t REG_DWORD /f
reg add "hku\temp\software\microsoft\windows\currentversion\explorer\advanced" /v ShowTaskViewButton /d 0 /t REG_DWORD /f
reg add "hku\temp\software\microsoft\windows\currentversion\explorer\advanced\People" /v PeopleBand /d 0 /t REG_DWORD /f
reg add "hku\temp\software\Microsoft\Windows\CurrentVersion\Search" /v SearchboxTaskbarMode /d 0 /t REG_DWORD /f 
# Set IE 11 home page
Write-Host "Setting Internet Explorer 11 home page" -ForegroundColor Green
reg add "hku\temp\software\microsoft\Internet Explorer" /v "Start Page" /d "http://www.cccd.edu" /t REG_SZ /f
# Disable Edge first run
Write-Host "Disabling Microsoft Edge first run..." -ForegroundColor Green
reg add "hku\temp\software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\FirstRun" /v "LastFirstRunVersionDelivered" /t REG_DWORD /d 1 /f
reg add "hku\temp\software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\Main" /v "IE10TourShown" /t REG_DWORD /d 1 /f
reg add "hku\temp\software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\Main" /v "DisallowDefaultBrowserPrompt" /t REG_DWORD /d 1 /f
#reg add "hku\temp\software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\Main" /v "HomeButtonEnabled" /t REG_DWORD /d 1 /f
#reg add "hku\temp\software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\Main" /v "HomeButtonPage" /t REG_SZ /d "https://www.cccd.edu" /f
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
reg unload "hku\temp"
Write-Host ""

# Disable firewall nag on 1903
Write-Host "Disable firewall notification on W10 1903"
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender Security Center\Notifications" /v DisableNotifications /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Notifications" /v DisableNotifications /t REG_DWORD /d 1 /f
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

# Disable show recently added in start menu
Write-Host "Disabling show recently added in start menu" -ForegroundColor Cyan
reg add HKLM\Software\Policies\Microsoft\Windows\Explorer /v HideRecentlyAddedApps /t REG_DWORD /d 1 /f
Write-Host ""

# Disable New Network Dialog
Write-Host "Disabling New Network Dialog" -ForegroundColor Green
reg add hklm\system\currentcontrolset\control\network\NewNetworkWindowOff
Write-Host ""

# Set power configuration
#Write-Host "Disabling Hibernate"
#powercfg -h off
Write-Host "Setting monitor timeout"
powercfg -change -monitor-timeout-ac 30
#Write-Host "Disabling sleep timeout"
#powercfg -change -standby-timeout-ac 0
Write-Host ""

# Disable privacy settings menu
Write-Host "Setting privacy settings menu for new users" -ForegroundColor Green
Write-Host ""
New-ItemProperty -path 'HKLM:\Software\Policies\Microsoft\Windows\OOBE' -Name 'DisablePrivacyExperience' -PropertyType DWORD -Value '1' | Out-Null

# Disable edge shortcut
Write-Host "Disable edge icon for new users" -ForegroundColor Green
Write-Host ""
New-ItemProperty -path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer' -Name 'DisableEdgeDesktopShortcutCreation' -PropertyType DWORD -Value '1' | Out-Null

# Enable RDP
#Write-Host "Enabling RDP" -ForegroundColor Green
#reg add "hklm\system\currentcontrolset\control\terminal server" /v fDenyTSConnections /t REG_DWORD /d 0 /f
#Write-Host ""

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
