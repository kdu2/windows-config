@echo off
set /p classroom=Enter classroom:

@echo on
for /f %%n in (%classroom%.txt) do (
	del "\\%%n\c$\users\public\desktop\shortcut.lnk"

)
pause
