cd /d %userprofile%\vsnotes\journal
set /p year="Enter year: "
set /p leapyear="Leapyear (y/n): "
if not exist %year% mkdir %year%
for %%m in (01-January 02-February 03-March 04-April 05-May 06-June 07-July 08-August 09-September 10-October 11-November 12-December) do (
	setlocal enabledelayedexpansion
	mkdir %year%\%%m	
	set mtemp=%%m
	set mfolder=!mtemp:~3!
	for /l %%d in (1,1,9) do (type nul>> %year%\%%m\!mfolder!_0%%d_%year%.txt)
	for /l %%d in (10,1,31) do (type nul>> %year%\%%m\!mfolder!_%%d_%year%.txt)
    endlocal
)

if %leapyear% == 'n' del %year%\02-February\February_29_%year%.txt /q /s

for %%f in (
    02-February\February_30_%year%.txt
    02-February\February_31_%year%.txt
    04-April\April_31_%year%.txt
    06-June\June_31_%year%.txt
    09-September\September_31_%year%.txt
    11-November\November_31_%year%.txt    
) do (del %year%\%%f /q /s)

pause
