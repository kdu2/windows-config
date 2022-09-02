for /l %%y in (2010,1,2020) do (
	cd /d %userprofile%\vsnotes\journal\%%y
	for %%m in (01-January 02-February 03-March 04-April 05-May 06-June 07-July 08-August 09-September 10-October 11-November 12-December) do (
		setlocal enabledelayedexpansion
		set mtemp=%%m
		set mfolder=!mtemp:~3!
		if exist !mfolder! ren !mfolder! %%m
		endlocal
	)
)
pause
