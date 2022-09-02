param(
    [string]$ConnectionServer,
    [string]$vcenter
)

Import-Module vmware.hv.helper
Import-Module vmware.vimautomation.core
if (!$global:defaulthvservers) {
    $hvuser = Read-Host -Prompt "Username"
    $hvpwd = Read-Host -AsSecureString -Prompt "Password"
    $cred = New-Object System.Management.Automation.PSCredential("saddleback\$hvuser",$hvpwd)    
    Connect-HVServer -Server $ConnectionServer -Credential $cred
}
if (!$global:defaultviservers) {
    if (!$cred) {
        $hvuser = Read-Host -Prompt "Username"
        $hvpwd = Read-Host -AsSecureString -Prompt "Password"
        $cred = New-Object System.Management.Automation.PSCredential("saddleback\$hvuser",$hvpwd)    
    }
    Connect-VIServer -Server $vcenter -Credential $cred
}
$pools = Get-HVPool

$PoolList = @()
$date = Get-Date -Format yyyy-MM-dd

foreach ($pool in $pools) {
    if ($pool.type -eq "AUTOMATED") {
        Write-Host "Getting info for $($pool.base.name)"
        $parentvm = Get-VM (($pool.AutomatedDesktopData.VirtualCenterNamesData.ParentVmPath -Split '/')[-1])
        $obj = New-Object PSObject -Property @{
            "Name" = $pool.base.Name
            "DisplayName" = $pool.base.displayname
            "ParentVM" = $parentvm.name
            "CPU" = $parentvm.numcpu
            "RAM" = $parentvm.memorygb
            "desktoptotal" = $pool.AutomatedDesktopData.VmNamingSettings.PatternNamingSettings.MaxNumberOfMachines
        }
        $PoolList += $obj
    }
}
$PoolList | Sort-Object ParentVM | Select-Object name,displayname,desktoptotal,ParentVM,CPU,RAM | Export-Csv -NoTypeInformation "C:\temp\$connectionserver-poolinfospecs-$date.csv"
