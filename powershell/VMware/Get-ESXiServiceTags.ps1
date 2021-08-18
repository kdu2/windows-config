if (!$global:defaultviserver) { 
    $vcenter = Read-Host -Prompt "vCenter"
    Connect-VIServer -Server $vcenter -Credential (Get-Credential)
}

$hostname = Get-View -ViewType HostSystem -property name,Hardware.SystemInfo
foreach ($hname in $hostname) {
    $hn = $hname.name
    $Man = $hname.Hardware.SystemInfo.Vendor
    $Mod = $hname.Hardware.SystemInfo.Model
    $serviceTag = $($hname.Hardware.SystemInfo.OtherIdentifyingInfo | where {$_.IdentifierType.Key -eq “ServiceTag” }).IdentifierValue

    $hname | Add-Member -MemberType NoteProperty -Name VMHost -Value $hn
    $hname | Add-Member -MemberType NoteProperty -Name OEM -Value $Man
    $hname | Add-Member -MemberType NoteProperty -Name Model -Value $Mod
    $hname | Add-Member -MemberType NoteProperty -Name ServiceTag -Value $serviceTag
}

$hostname | select VMHost, OEM, Model, ServiceTag
