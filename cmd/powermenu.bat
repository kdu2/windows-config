@echo off
echo shutdown options:
echo   s = shutdown
echo   r = restart
echo   c = cancel (or close window)
set /p power=Enter option:
if %power% == c (
    echo shutdown cancelled. exiting...
	exit
) 
shutdown /%power% /t 5
pause
