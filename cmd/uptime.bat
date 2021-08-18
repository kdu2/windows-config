@echo off
powershell -noprofile -command "(get-date)-(get-ciminstance -class win32_operatingsystem).lastbootuptime | select days,hours,minutes,seconds"
pause
