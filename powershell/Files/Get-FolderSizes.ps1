# script to gather folder sizes

# input argument is path to read for subfolders
param([string]$path)

# for debugging
#$path = "D:\folder"
$ErrorActionPreference= 'silentlycontinue'

# Globals
$date = Get-Date -Format "MM-dd-yyyy"
$root_folder = @()
$folders = @()
$subfolders = @()
$Count = 0
$timer = @()
$timer = [Diagnostics.Stopwatch]::StartNew()

# set subfolders
if (!$(Test-Path $path)) {
    Write-Host "Folder: $path was not found on the file system"
} else {
    $folders = Get-ChildItem -Directory $path
}

if ($folders) {
	Write-Host $folders.Count " folders to grab sizes from..."
	foreach ($subfolder in $folders) {
        $root_folder_temp = @()
        $temp_folder = @()
        $root_folder_temp = New-Object System.Object

        # Get the folder's file size complete with hidden files	and divide the size to get number of GB's
        $root_folder_temp | Add-Member -MemberType NoteProperty -Name folder -Value $subfolder.name
        $temp_folder = Get-ChildItem $item -Recurse -Force | Measure-Object -Sum Length
        $root_folder_temp | Add-Member -MemberType NoteProperty -Name Size_GB -Value $('{0:N1}' -f ($temp_folder.Sum/1GB))
        $root_folder_temp | Add-Member -MemberType NoteProperty -Name Size_MB -Value $('{0:N1}' -f ($temp_folder.Sum/1MB))
        $root_folder += $root_folder_temp
        Write-Host "Sized folder " $subfolder.Name
        $Count++
	    Write-Host $Count "of " $folders.Count " processed - " $('{0:N1}' -f (($Count/$folders.Count)*100)) "%"
    }
} else {
	Write-Host "No folders found..."
}
if ($root_folder) {
    $root_folder | Sort-Object -Descending @{e={$_.SizeMB -as [double]}} | Export-CSV "Folder-Sizes-$date.csv" -force -NoTypeInformation
    Write-Host "Exporting 'Folder-Sizes-$date.csv' to local working directory..."
} else {
	Write-Host "Nothing to export..."
}

$timer.Stop()
Write-Host "[Script Execution Time(H:M:S): " $timer.Elapsed.Hours ":" $timer.Elapsed.Minutes ":" $timer.Elapsed.Seconds "]"
