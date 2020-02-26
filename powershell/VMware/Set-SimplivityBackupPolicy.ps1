param(
    [string]$vcenter,
    [string]$folder,
    [string]$hosts,
    [string]$OVC,
    [string]$policy
)

Import-Module vmware.vimautomation.core
Import-Module hpesimplivity

$secpwd = Get-Content "path\file.txt" | ConvertTo-SecureString -Key (1..32)
$cred = New-Object System.Management.Automation.PSCredential ("domain\user", $secpwd)

Connect-VIServer -Server $vcenter -Credential $cred

$SimplivityVMs = Get-VM -Location $folder | Where-Object { $_.VMHost -like "$($hosts)*" }

Connect-SVT -OVC $OVC -Credential $cred

foreach ($vm in $SimplivityVMs) {
    $SVTvm = Get-SVTvm -VmName "$($vm.name)"
    if ($SVTvm.PolicyName -ne $policy) {
        Set-SVTvmPolicy -PolicyName $policy -VmName "$($vm.name)"
    }    
}
