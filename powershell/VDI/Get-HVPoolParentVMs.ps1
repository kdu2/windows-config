# get parent vm's of desktop pools
param(
    [Parameter(Mandatory=$true)]    
    [string]$ConnectionServer
)

Import-Module vmware.hv.helper
if (!$global:defaulthvservers) {
    $hvuser = Read-Host -Prompt "Username"
    $hvpwd = Read-Host -AsSecureString -Prompt "Password"
    $domain = Read-Host -Prompt "Domain"
    $cred = New-Object System.Management.Automation.PSCredential("$domain\$hvuser",$hvpwd)
    Connect-HVServer -Server $ConnectionServer -Credential $cred
}

$pools = Get-HVPool

$PoolList = @()

foreach ($pool in $pools) {
    if ($pool.type -eq "AUTOMATED") {
        $parentvm = ($pool.AutomatedDesktopData.VirtualCenterNamesData.ParentVmPath -Split '/')[-1]
        $parentsnapshot = ($pool.AutomatedDesktopData.VirtualCenterNamesData.SnapshotPath -Split '/')[-1]
        $obj = New-Object PSObject -Property @{
            "Name" = $pool.base.Name
            "DisplayName" = $pool.base.displayname
            "ParentVM" = $parentvm
            "Snapshot" = $parentsnapshot
        }
        $PoolList += $obj
    }
}

$PoolList | Sort-Object ParentVM | Select-Object Name,ParentVM,Snapshot | Export-Csv -NoTypeInformation "c:\temp\$connectionserver-poolparentvm.csv"
