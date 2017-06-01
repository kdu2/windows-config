reg delete "hkcu\local settings\software\microsoft\windows\currentversion\traynotify" /v iconstreams /f
reg delete "hkcu\local settings\software\microsoft\windows\currentversion\traynotify" /v pasticonsstream /f

powershell "stop-process -name explorer"
