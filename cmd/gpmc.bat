@echo off
powershell start-process -filepath cmd -argumentlist "/c","mmc","gpmc.msc" -credential (load-credential)