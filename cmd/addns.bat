@echo off
runas /user:saddleback\kdu-d "cmd /c mmc dnsmgmt.msc"
powershell start-process -filepath cmd -argumentlist "/c","mmc","dnsmgmt.msc" -credential (load-credential)