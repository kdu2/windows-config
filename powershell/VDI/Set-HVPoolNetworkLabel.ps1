# this script sets the network label for a Horizon desktop pool
# this allows you to use a different portgroup/vlan than the one assigned to the parent vm for linked clones (an instant clone pool only feature in the View Admin gui)
# based on original script from Wouter Kursten
# https://www.retouw.nl/powercli/multi-vlan-network-for-horizon-view-using-powercli-apis/
# https://github.com/Magneet/Various_Scripts/blob/master/configure_Linked_clone_pool_vlans.ps1

param(
    [Parameter(Mandatory=$true)]
    [string]$ConnectionServer,
    [Parameter(Mandatory=$true)]
    [string]$pool,
    [Parameter(Mandatory=$true)]
    [string]$label,
    [int]$maxlabels=500
)

Import-Module vmware.hv.helper

$hvserver = Connect-HVServer -Server $ConnectionServer
$services = $hvserver.ExtensionData

$queryService = New-Object VMware.Hv.QueryServiceService
$defn = New-Object VMware.Hv.QueryDefinition
$defn.queryEntityType = 'DesktopSummaryView'
$defn.filter = New-Object VMware.Hv.QueryFilterEquals -property @{'memberName'='desktopSummaryData.name'; 'value' = $pool}
try {
    $poolid=($queryService.queryservice_create($services, $defn)).results
} catch { 
    throw "Can't find $pool, exiting" 
}

$hvpool = $services.desktop.desktop_get($poolid.id)
$allnetworklabels = $services.networklabel.NetworkLabel_ListByHostOrCluster($hvpool.AutomatedDesktopData.VirtualCenterProvisioningSettings.VirtualCenterProvisioningData.hostorcluster)
$networklabels = $allnetworklabels | Where-Object { $_.data.name -like $label }
$nic = $services.NetworkInterfaceCard.NetworkInterfaceCard_ListBySnapshot($hvpool.AutomatedDesktopData.VirtualCenterProvisioningSettings.VirtualCenterProvisioningData.snapshot)

$NetworkLabelAssignmentSpecs = @()

foreach ($networklabel in $networklabels) {
    $NetworkLabelAssignmentSpec = New-Object VMware.Hv.DesktopNetworkLabelAssignmentSpec
    $NetworkLabelAssignmentSpec.enabled = $true
    $NetworkLabelAssignmentSpec.networklabel = $networklabel.id
    $NetworkLabelAssignmentSpec.maxlabeltype = "LIMITED"
    $NetworkLabelAssignmentSpec.MaxLabel = $maxlabels
    $NetworkLabelAssignmentSpecs += $NetworkLabelAssignmentSpec
}

$nicsettings = New-Object VMware.Hv.DesktopNetworkInterfaceCardSettings
$nicsettings.nic = $nic.id
$nicsettings.NetworkLabelAssignmentSpecs = $NetworkLabelAssignmentSpecs

$VirtualCenterNetworkingSettings = @()
$VirtualCenterNetworkingSettings = New-Object VMware.Hv.DesktopVirtualCenterNetworkingSettings
$VirtualCenterNetworkingSettings.nics += $nicsettings

$desktopService = New-Object VMware.Hv.DesktopService
$desktopInfoHelper = $desktopService.read($services, $hvpool.id)
$desktopInfoHelper.GetAutomatedDesktopDataHelper().GetVirtualCenterProvisioningSettingsHelper().SetVirtualCenterNetworkingSettingsHelper($VirtualCenterNetworkingSettings)
$desktopService.Update($services, $desktopInfoHelper)
