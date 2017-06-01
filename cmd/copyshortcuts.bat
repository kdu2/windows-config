@echo off
set /p classroom=Enter classroom:

@echo on
for /f %%n in (%classroom%.txt) do (
	copy "\\%%n\c$\programdata\microsoft\windows\start menu\programs\folder\shortcut.lnk" "\\%%n\c$\users\public\desktop\shortcut.lnk"
)
pause
