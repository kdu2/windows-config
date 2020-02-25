## Set up FileSystemWatcher
# MS Reference: https://msdn.microsoft.com/en-us/library/system.io.filesystemwatcher(v=vs.110).aspx
# Watches %temp% for changes in file names or file writes for MSI files
# Current versions of GoogleEarth no longer use '.tmp' as the extension
$Watcher = New-Object System.IO.FileSystemWatcher
$Watcher.Path = $env:temp
$Watcher.Filter = "*.msi"
$Watcher.IncludeSubdirectories = $false
$Watcher.EnableRaisingEvents = $true 
$Watcher.NotifyFilter = [System.IO.NotifyFilters]'FileName, LastWrite'

## Set up event handler
$Action = {
    $Path = $Event.SourceEventArgs.FullPath 
    Write-Host "Found Installer:" $Path 
    Copy-Item $Path C:\temp -Force
    Write-Host "Gotcha! Installer copied to C:\temp"
}

## Register the event and wait until it's done
$Event = Register-ObjectEvent -InputObject $Watcher -EventName "Changed" -Action $Action -MaxTriggerCount 1 
while ($Event.State -eq 'NotStarted') {Start-Sleep 1}
