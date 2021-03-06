$PCoIPLog_Source = "C:\ProgramData\VMware\VDM\logs"    
$PCoIPLog_Dest = "\\server\share\" + $env:computername
$PCoIPLog_Files = Get-ChildItem $PCoIPLog_Source
if ($PCoIPLog_Files) {
	if (!(Test-Path $PCoIPLog_Dest)) { New-Item -ItemType Directory -Path $PCoIPLog_Dest -Force }
	foreach ($file in $PCoIPLog_Files) { Copy-Item "$PCoIPLog_Source\$file" -Destination $PCoIPLog_Dest -Force } 
}
