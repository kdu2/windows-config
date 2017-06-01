@echo off
REM  This script will:
REM       + silently install or upgrade Firefox WITHOUT Firefox being the default browser
REM       + Disables the 'Automatically check for updates' option
REM       + Disables the 'Always check to see if Firefox is the default browser on startup' option
REM       + Disables the Import Wizard
REM       + Works for Windows XP / 7 / 8 / 10 32-bit and 64-bit
REM .
REM===========================================
echo Installing Firefox - Please Wait.
echo Window will close after install is complete
REM Installing Firefox
"%~dp0Firefox Setup.exe" -ms
REM Install 32-bit customisations
if exist "%programfiles%\Mozilla Firefox\" copy /Y "%~dp0override.ini" "%programfiles%\Mozilla Firefox\browser\"
if exist "%programfiles%\Mozilla Firefox\" copy /Y "%~dp0mozilla.cfg" "%programfiles%\Mozilla Firefox\"
if exist "%programfiles%\Mozilla Firefox\" copy /Y "%~dp0local-settings.js" "%programfiles%\Mozilla Firefox\defaults\pref"
REM Install 64-bit customisations
if exist "%ProgramFiles(x86)%\Mozilla Firefox\" copy /Y "%~dp0override.ini" "%ProgramFiles(x86)%\Mozilla Firefox\browser\"
if exist "%ProgramFiles(x86)%\Mozilla Firefox\" copy /Y "%~dp0mozilla.cfg" "%ProgramFiles(x86)%\Mozilla Firefox\"
if exist "%ProgramFiles(x86)%\Mozilla Firefox\" copy /Y "%~dp0local-settings.js" "%ProgramFiles(x86)%\Mozilla Firefox\defaults\pref"
REM Moves Firefox Desktop Icon - Windows 7 / 8 / 10
if exist "%public%\Desktop\Mozilla Firefox.lnk" move "%public%\Desktop\Mozilla Firefox.lnk" "C:\Users\Default\Desktop\Mozilla Firefox.lnk"
