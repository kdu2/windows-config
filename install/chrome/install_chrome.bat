echo Installing Chrome - Please Wait
echo Window will pause after install is complete
REM Installing Chrome
if exist "%~dp0ChromeStandAlone.exe" "%~dp0ChromeStandaloneSetup.exe" /silent /install
if exist "%~dp0ChromeStandAlone64.exe" "%~dp0ChromeStandaloneSetup64.exe" /silent /install
if exist "%programfiles%\Google\Chrome\Application\" copy /y "%~dp0master_preferences" "%programfiles%\Google\Chrome\Application\"
if exist "%programfiles(x86)%\Google\Chrome\Application\" copy /y "%~dp0master_preferences" "%programfiles(x86)%\Google\Chrome\Application\"
if exist "%public%\Desktop\Google Chrome.lnk" move "%public%\Desktop\Google Chrome.lnk" "C:\Users\Default\Desktop\Google Chrome.lnk"
pause
