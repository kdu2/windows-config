@echo off
set /p building=Enter building and classroom number: 

set /p computers=Enter number of computers: 

set /p lab=Enter lab designation: 

set /p file=Enter file name: 

@echo on

for /l %%n in (1,1,9) do (echo G%building%-%lab%0%%nD>> %file%.txt)

for /l %%n in (10,1,%computers%) do (echo G%building%-%lab%%%nD>> %file%.txt)

pause
