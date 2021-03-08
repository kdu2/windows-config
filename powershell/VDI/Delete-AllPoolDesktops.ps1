param(
    [string]$pool,
    [string]$ConnectionServer,
    [string]$vCenter,
    [string]$composer,
    [string]$composeradmin,
    [string]$composerpassword
)

Import-Module VMware.Hv.Helper
Import-Module VMware.VimAutomation.Core
Import-Module ActiveDirectory

Connect-HVServer -Server $ConnectionServer
Connect-VIServer -Server $vCenter

# get list of vm's
$machines = Get-HVMachine -PoolName $pool

foreach ($machine in $machines) {
    # delete ADAM DB object
    Write-Host "Deleting $($machine.base.name) from ADAM DB"
    $ldap = "LDAP://$ConnectionServer`:389/OU=Servers,dc=vdi,dc=vmware,dc=int"
    $root = New-Object System.DirectoryServices.DirectoryEntry $ldap
    $query = New-Object System.DirectoryServices.DirectorySearcher
    $query.searchroot = $root
    $query.Filter = "(&(objectClass=pae-VM)(pae-DisplayName=$($machine.base.name))"
    $result = $query.findone()
    $desktop = $result.getdirectoryentry()
    $desktop.deleteobject(0)

    # delete AD computer object
    Write-Host "Deleting $($machine.base.name) from AD"
    Remove-ADComputer -Identity $($machine.base.name)

    # power off and delete vcenter vm's
    Write-Host "Powering off and deleting $($machine.base.name) from vCenter"
    Stop-VM -VM $($machine.base.name) | Remove-VM

    # delete composer db vm entry
    Write-Host "Deleting $($machine.base.name) from Composer DB"
    Start-Process -FilePath "C:\Program Files (x86)\VMware\VMware View Composer\SviConfig.exe" -ArgumentList  "-operation=RemoveSviClone", "-VmName=$($machine.base.name)", "-AdminUser=$composeradmin", "-AdminPassword=$composerpassword", "-ServerUrl=https://$composer`:18443/SviService/v3_5" -Wait
}
