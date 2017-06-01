@echo off
REM run as admin before shutdown/snapshot for new image recompose
@echo on
REM *********************
REM Stop and disable update services
REM *********************
net stop wuauserv
sc config wuauserv start= disabled
net stop adobearmservice
net stop adobeflashplayerupdatesvc
sc config adobearmservice start= disabled
sc config adobeflashplayerupdatesvc start= disabled
net stop adobeupdateservice
sc config adobeupdateservice start= disabled
net stop gupdate
net stop gupdatem
sc config gupdate start= disabled
sc config gupdatem start= disabled
REM *********************
REM End and disable scheduled tasks
REM *********************
schtasks /end /tn "Adobe Acrobat Update Task"
schtasks /end /tn "Adobe Flash Player Task"
schtasks /change /tn "Adobe Acrobat Update Task" /disable
schtasks /change /tn "Adobe Flash Player Updater" /disable
schtasks /end /tn "googleupdatetaskmachinecore"
schtasks /end /tn "googleupdatetaskmachineua"
schtasks /change /tn "googleupdatetaskmachinecore" /disable
schtasks /change /tn "googleupdatetaskmachineua" /disable
REM *********************
REM prep Stratusphere agent
REM *********************
sc config tntgrd start= demand
sc config tntuidsvc start= demand
sc config tntupdsvc start= demand
"c:\Program Files (x86)\Liquidware Labs\Connector ID\idcontrol.exe" clean
REM *********************
REM Delete any existing shadow copies
REM *********************
vssadmin delete shadows /All /Quiet
REM *********************
REM delete files in c:\Windows\SoftwareDistribution\Download\
REM *********************
del c:\Windows\SoftwareDistribution\Download\*.* /f /s /q
REM *********************
REM delete hidden install files
REM *********************
del %windir%\$NT* /f /s /q /a:h
REM *********************
REM delete prefetch files
REM *********************
del c:\Windows\Prefetch\*.* /f /s /q
REM *********************
REM Run Disk Cleanup to remove temp files, empty recycle bin
REM and remove other unneeded files
REM Note: Makes sure to run c:\windows\system32\cleanmgr /sageset:1 command 
REM       on your initially created parent image and check all the boxes 
REM       of items you want to delete 
REM *********************
c:\windows\system32\cleanmgr /sagerun:1
REM ********************
REM Defragment the VM disk
REM ********************
sc config defragsvc start= auto
net start defragsvc
defrag c: /U /V
net stop defragsvc
sc config defragsvc start = disabled
REM *********************
REM Clear all event logs
REM *********************
wevtutil el 1>cleaneventlog.txt
for /f %%x in (cleaneventlog.txt) do wevtutil cl %%x
del cleaneventlog.txt
REM *********************
REM release IP address
REM *********************
ipconfig /release
REM *********************
REM Flush DNS
REM *********************
ipconfig /flushdns
REM *********************
REM Shutdown VM
REM *********************
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
