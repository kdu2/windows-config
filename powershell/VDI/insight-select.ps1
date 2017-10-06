# Select Insight channel based on client name

# get client and desktop pool name from environment variable after login
$clientname = Get-ItemPropertyValue -path 'HKCU:\Volatile Environment' -Name ViewClient_Machine_Name
$pool = Get-ItemPropertyValue -Path 'HKCU:\Volatile Environment' -Name ViewClient_Launch_ID

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
    $process = Get-Process | where { $_.name -eq "student" }
    if ($process -ne $null) { Stop-Process -Name "student" -Force }
    Set-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\Insight" -Name "Channel" -Type "DWORD" -Value $channel -Force
    Start-Process -FilePath "C:\Program Files (x86)\Faronics\Insight\student.exe"
    Copy-Item -Path "$filepath\Insight Files.lnk" -Destination "$env:userprofile\Desktop"
}
