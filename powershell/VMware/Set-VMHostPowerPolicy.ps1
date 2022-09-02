param(
    #[Parameter(Mandatory=$true)]
    #[ValidateSet("High","Balanced","Low","Custom")]
    #[string]$PowerPolicy,
    [string]$vcenter
)

if (!$global:defaultviservers) { Connect-VIServer -Server $vcenter}

$VMHosts = Get-VMHost

foreach ($VMHost in $VMHosts) {
    $view = Get-View $VMHost
    <#
    $current_policy    
    if ($PowerPolicy -ne $current_policy) {
        $policycode = 0
        switch ($PowerPolicy) {
            "High"      { $policycode = 1 }
            "Balanced"  { $policycode = 2 }
            "Low"       { $policycode = 3 }
            "Custom"    { $policycode = 4 }
            default     {}
        }
        Write-Host "Setting $vmhost to $powerpolicy" -Foregroundcolor Green
        (Get-View $view.ConfigManager.PowerSystem).ConfigurePowerPolicy($policycode)
    }
    #>
    Write-Host "Setting $vmhost to High Performance" -Foregroundcolor Green
    (Get-View $view.ConfigManager.PowerSystem).ConfigurePowerPolicy(1) 
}
