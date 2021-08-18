@echo off
powershell start-process -filepath cmd -argumentlist "/c","mmc","dsa.msc" -credential (load-credential)
