param(
    [Parameter(Mandatory=$true)]
    [string]$connectionserver
)

Import-Module vmware.hv.helper

if (!$global:defaulthvservers) {
    $hvuser = Read-Host -Prompt "Username"
    $hvpwd = Read-Host -AsSecureString -Prompt "Password"
    $cred = New-Object System.Management.Automation.PSCredential("saddleback\$hvuser",$hvpwd)    
    Connect-HVServer -Server $ConnectionServer -Credential $cred
}

$pools = Get-HVPool

$date = Get-Date -Format yyyy-MM-dd

$entitlements = @()

foreach ($pool in $pools) {
    Write-Host "Getting entitlements for $($pool.base.name)"
    $pool_entitlements = (Get-HVEntitlement -ResourceName $pool.base.name).base | Select-Object DisplayName
    foreach ($pool_entitlement in $pool_entitlements) {
        $obj = New-Object PSObject -Property @{
            "Name" = $pool.base.name
            "Entitlement" = $pool_entitlement.DisplayName
        }
        $entitlements += $obj
    }    
}

$entitlements | Sort-Object Name | Select-Object Name,Entitlement | Export-Csv -NoTypeInformation "C:\temp\$connectionserver-poolentitlements-$date.csv"
#$entitlements | Sort-Object Name | Select-Object Name,Entitlement
