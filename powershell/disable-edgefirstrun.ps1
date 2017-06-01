# disable Microsoft Edge first run and change default browser prompt

do {
     Start-Sleep -Milliseconds 2000
     $Exhausted++
} While (!(Test-Path -path "HKCU:\SOFTWARE\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe") -and $Exhausted -lt 31)
 if($Exhausted -gt 30) {
     exit 1
}
New-Item -Path "HKCU:\SOFTWARE\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge" -type Directory
New-Item -Path "HKCU:\SOFTWARE\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\Firstrun" -type Directory
New-Item -Path "HKCU:\SOFTWARE\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\Main" -type Directory
# These two values removes the Edge Welcome screen
new-itemproperty "HKCU:\SOFTWARE\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\FirstRun" -Name "LastFirstRunVersionDelivered" -Value 1 -Type DWORD -Force -ErrorAction SilentlyContinue | Out-Null
new-itemproperty "HKCU:\SOFTWARE\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\Main" -Name IE10TourShown -Value 1 -Type DWORD -Force -ErrorAction SilentlyContinue | Out-Null
# This registry entry disables the prompt to make Edge the default browser
new-itemproperty "HKCU:\SOFTWARE\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\Main" -Name "DisallowDefaultBrowserPrompt" -Value 1 -Type DWORD -Force -ErrorAction SilentlyContinue | Out-Null
