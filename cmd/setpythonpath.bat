@echo off
set /p classroom=Enter classroom: 

@echo on
for /f %%n in (%classroom%.txt) do (
    setx /m /s \\%%n PYTHONPATH "C:\Apps\python36"
)

pause
