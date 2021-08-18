@echo off
powershell start-process -filepath cmd -argumentlist "/c","mmc","dhcpmgmt.msc" -credential (load-credential)