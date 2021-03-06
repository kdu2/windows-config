# script to gather profile sizes from a list of specified computers

# input argument is name of csv file to read for hostnames
param([string]$hostnamescsv)

$ErrorActionPreference= 'silentlycontinue'

#Globals
$date = Get-Date -Format "MM-dd-yyyy"
$LocalProfiles = @()
$Master_Profile_Obj = @()
$Hostnames = @()
$Count = 0
$timer = @()
$timer = [Diagnostics.Stopwatch]::StartNew()

# Load a CSV
if (!$(Test-Path $hostnamescsv)) {
        # Do nothing - file not found
		Write-Host "File: $HostnamesCSV was not found on the file system"
} else {
        $Hostnames += Import-Csv $HostnamesCSV
		# Example CSV format:
		# Hostname
		# machine1,machine2,machine3
}

if ($Hostnames) {
	Write-Host $Hostnames.Count " machines to grab profiles from..."
	foreach ($RemoteHost in $Hostnames) {
	    $RemoteProfilePath = @()
	    $RemoteProfilePath = "\\" + $RemoteHost.Hostname + "\c$\Users"
	    $LocalProfiles = Get-ChildItem $RemoteProfilePath
	    foreach ($userprofile in $LocalProfiles) {
		    $ProfilePath = @()
		    $Master_Profile_Obj_temp = @()
		    $temp_prof = @()
		    $Master_Profile_Obj_temp = New-Object System.Object
            
            # ignore the following profiles
            if ($userprofile.Name -like "Public") { }
		    elseif ($userprofile.Name -like "Default*") { }
		    elseif ($userprofile.Name -like "Administrator*") { }
		    elseif ($userprofile.Name -like "admin*") { }

            # calculate remaining profiles
            else {
			    $ProfilePath = $RemoteProfilePath + "\" + $userprofile.Name
			    #Get the folder's file size complete with hidden files	and divide the size to get # of GB
			    $Master_Profile_Obj_temp | Add-Member -MemberType NoteProperty -Name Hostname -Value $RemoteHost.Hostname
			    $Master_Profile_Obj_temp | Add-Member -MemberType NoteProperty -Name Profile -Value $userprofile.Name
			    $temp_prof = Get-ChildItem $ProfilePath -Recurse -Force -Exclude @("*.ost","temp") | Measure-Object -Sum Length
			    $Master_Profile_Obj_temp | Add-Member -MemberType NoteProperty -Name Size_GB -Value $('{0:N1}' -f ($temp_prof.Sum/1GB))
			    $Master_Profile_Obj_temp | Add-Member -MemberType NoteProperty -Name Size_MB -Value $('{0:N1}' -f ($temp_prof.Sum/1MB))
			    $Master_Profile_Obj += $Master_Profile_Obj_temp
			    Write-Host "Sized profile '" $userprofile.Name "' on '" $RemoteHost.Hostname "'"
            }
        }
	    $Count++
	    write-host $Count "of " $Hostnames.Count " processed - " $('{0:N1}' -f (($Count/$Hostnames.Count)*100)) "%"
    }
} else {
	Write-Host "No hostnames found..."
}
if ($Master_Profile_Obj) {
	#$Master_Profile_Obj | Sort-Object -Property Hostname,User,Size_GB -Descending | Export-CSV "PROFILE-SIZES.CSV" -force -NoTypeInformation
	$Master_Profile_Obj | Sort-Object -Descending @{e={$_.SizeMB -as [double]}} | Export-CSV "GWC-PROFILE-SIZES-$date.CSV" -force -NoTypeInformation
    Write-Host "Exporting 'GWC-PROFILE-SIZE-$date.CSV' to local working directory..."
} else {
	Write-Host "Nothing to export..."
}

$timer.Stop()
Write-Host "[Script Execution Time(H:M:S): " $timer.Elapsed.Hours ":" $timer.Elapsed.Minutes ":" $timer.Elapsed.Seconds "]"
