# remove app stacks that did not detach correctly after logoff

param([string]$foldername)

Add-PSSnapin VMware.VimAutomation.Core -ErrorAction SilentlyContinue
Write-Host "Imported vSphere PowerCLI module"

Connect-VIServer vcenterserver
Write-Host "Connected to vCenter"

$pooltotal = (Get-Folder $foldername | Get-VM).count

Write-Host "Desktop pool total is $pooltotal"

# end of script
