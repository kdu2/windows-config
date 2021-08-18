function Get-Uptime {
    (Get-Date) - (Get-CimInstance -class win32_operatingsystem).LastBootUpTime | Select-Object days,hours,minutes,seconds
}