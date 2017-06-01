%~dp0silverlight_x64.exe /q
reg add hklm\software\microsoft\silverlight /v UpdateMode /d 2 /t REG_DWORD /f
pause
