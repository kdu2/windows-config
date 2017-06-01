@echo off
set /p user=Enter user format:

set /p file=Enter file name: 

@echo on

for /l %%n in (1,1,30) do (echo %user%%%n >> %file%.csv)

pause