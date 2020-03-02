@echo off
shutdown -s -t 999999
if %ERRORLEVEL% equ 1190 (
  echo A shutdown is pending
) else (
  shutdown /a
  echo No shutdown is pending
)
