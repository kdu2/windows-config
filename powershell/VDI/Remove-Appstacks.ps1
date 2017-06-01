# remove app stacks that did not detach correctly after logoff

# specify name of file exported from view administrator containing list of machines
param([string]$list)

Add-PSSnapin VMware.VimAutomation.Core -ErrorAction SilentlyContinue

Connect-VIServer vcenterserver

$classroompool = Get-Content $list

foreach ($linkedclone in $classroompool) {
    $disks = Get-HardDisk -VM $linkedclone
    foreach ($disk in $disks) {
        $diskname = $disk.Filename
        $disksize = $disk.CapacityGB
        # assumes app stack volume size of 20GB
        if (($diskname -like "*folder/path/*") -and ($disksize -eq 20)) {
            Write-Host "VM $linkedclone - removing $diskname"
            Write-Output "VM $linkedclone - removing $diskname" | Out-File -Append "appstack-removal-$list.log"
            Remove-HardDisk $disk -Confirm:$false 2>> "appstack-removal-$list.log"
        }
    }
}
