# Select Insight channel based on client name

function log ([string]$entry) {
    Write-Output $entry | Out-File -Append "C:\logs\insight\insight-channel.log"
}

# get client and desktop pool name from environment variable after login
$clientname = Get-ItemPropertyValue -path 'HKCU:\Volatile Environment' -Name ViewClient_Machine_Name
$pool = Get-ItemPropertyValue -Path 'HKCU:\Volatile Environment' -Name ViewClient_Launch_ID

# set time and date format
$date = Get-Date -Format "MM-dd-yyyy"
$time = Get-Date -Format "hh:mm:sstt"

# create the directory if it doesn't exist
if (!(Test-Path C:\logs\insight)) { New-Item -ItemType Directory -Path C:\logs\insight }

# begin log
log $(Get-Date)

# record the zero client name, desktop name, and username
log "client:  $clientname"
log "desktop: $env:computername"
log "user:    $env:username"

# extract classroom number from clientname
# assumes format of [single letter campus][3 digit building][3 digit room]-[1 to 3 digit station number][single letter device type]
# e.g. O074123-01Z
# grabs characters 2 through 7 for the building and room number
$classroom = $clientname.Substring(1,6)

# set file path
$filepath = "\\server\share\folder"

# import classroom info from CSV file
# the CSV file has 3 fields listing the classrooms that are using Insight, the channel for that room, and if Insight is enabled for that room
$insightclassroom = Import-Csv "$filepath\insightclassrooms.csv" | Where-Object {$classroom -eq $_.room} | select room,channel,enabled

# valid pools
$pools = Get-Content "$filepath\insightpools.txt"

# check if classroom is valid
# configure Insight client with corresponding classroom channel or write error to log
if (($insightclassroom.room -eq $classroom) -and ($insightclassroom.enabled -eq 'Y') -and ($pools -contains $pool)) {    
    $channel = $insightclassroom.channel
    log "channel: $channel"
    $insightclient = "C:\Program Files (x86)\Faronics\Insight\student.exe"
    if (!(Test-Path $insightclient)) {
        log "insight: installing`n"
        Start-Process -FilePath msiexec -ArgumentList "/i $filepath\Student_v8.2379.msi /qn ADVANCEDOPTIONS=1 CHANNEL=$channel STEALTHMODE=1 LCS=10.20.84.45 INSTALL_CHROME_EXTENSION=1"
    } else {
        log "insight: installed`n"
        $process = Get-Process -Name "student"
        if ($process -ne $null) { $process | Stop-Process -Force }
        Set-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\Insight" -Name "Channel" -Type "DWORD" -Value $channel -Force
        Start-Process -FilePath $insightclient        
    }
    Copy-Item -Path "$filepath\Insight Files.lnk" -Destination "$env:userprofile\Desktop"
} else {
    log "status:  failed to find channel for $classroom`n"
}
