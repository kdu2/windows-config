# Copy settings to local desktop

function log ([string]$entry) {
    Write-Output $entry | Out-File -Append "C:\logs\settings.log"
}

# get client hostname from environment variable after login
$clientname = (Get-ItemProperty -Path 'HKCU:\Volatile Environment' -Name ViewClient_Machine_Name).ViewClient_Machine_Name

# create the directory if it doesn't exist
if (!(Test-Path C:\logs)) { New-Item -ItemType Directory -Path C:\logs }

# begin log
log $(Get-Date)

# record the zero client hostname
log "zero client hostname is $clientname"
log "username is $env:username"

# extract classroom number from hostname
# assumes format of [single letter site][3 digit building][3 digit room]-[1 to 3 digit station number][single letter device type]
# e.g. A001100-01Z
# grabs characters 2 through 7 for the room number
$classroom = $clientname.Substring(1,6)

# array of valid classrooms
$classrooms = Get-Content "\\server\share\scripts\vdiclassrooms.txt"

# extract desktop pool from environment variable after login
$pool = (Get-ItemProperty -Path 'HKCU:\Volatile Environment' -Name ViewClient_Launch_ID).ViewClient_Launch_ID

# list of valid pools
$pools = Get-Content "\\server\share\scripts\pools.txt"

# check if classroom is valid
if (($classrooms -contains $classroom) -and ($pools -contains $pool)) {
    if (!(Test-Path "C:\path\settings")) { New-item  -ItemType Directory -Path "C:\path\settings" }
    xcopy /e /i /q /y "\\server\share\folder\settings\*" "C:\path\settings"
    log "copying settings to C:\path\settings"
} else {
    log ("failed to find classroom for " + $classroom)
}
