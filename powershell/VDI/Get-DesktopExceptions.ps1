<#
.SYNOPSIS
   Get-DesktopExceptions is a script that will locate VMware View Linked Clones that are not using the correct snapshot/image.
.DESCRIPTION
   Get-DesktopExceptions will look in the View LDAP datastore to find the snapshot IDs used by the desktops and the pool.
   It compares these values to find any desktops that do not match the pool.
   In order to run this script, the Quest Active Directory Cmdlets will need to be installed.
.PARAMETER ConnectionServer
   The View Connection server that you want to run this script against.
#>

$ConnectionServer = "vcenterserver"

$date = Get-Date -Format "MM-dd-yyyy"
$log = "DesktopExceptions-$date.log"

Function Get-Pools
{
    param($ConnectionServer)

    $PoolList = @()

    $arrIncludedProperties = "cn,name,pae-DisplayName,pae-MemberDN,pae-SVIVmParentVM,pae-SVIVmSnapshot,pae-SVIVmSnapshotMOID".Split(",")
    $pools = Get-QADObject -Service $ConnectionServer -DontUseDefaultIncludedProperties -IncludedProperties $arrIncludedProperties -LdapFilter "(objectClass=pae-ServerPool)" -SizeLimit 0 | Sort-Object "pae-DisplayName" | Select-Object Name, "pae-DisplayName", "pae-SVIVmParentVM" , "pae-SVIVmSnapshot", "pae-SVIVmSnapshotMOID", "pae-MemberDN"

    ForEach ($pool in $pools)
    {
        $obj = New-Object PSObject -Property @{
            "cn" = $pool.cn
            "name" = $pool.name
            "DisplayName" = $pool."pae-DisplayName"
            "MemberDN" = $pool."pae-MemberDN"
            "SVIVmParentVM" = $pool."pae-SVIVmParentVM"
            "SVIVmSnapshot" = $pool."pae-SVIVmSnapshot"
            "SVIVmSnapshotMOID" = $pool."pae-SVIVmSnapshotMOID" }
        $PoolList += $obj
    }
    Return $PoolList
}

Function Get-Desktop
{
    param($MemberDN, $ConnectionServer)

    $arrIncludedProperties = "cn,name,pae-DisplayName,pae-MemberDN,pae-SVIVmParentVM,pae-SVIVmSnapshot,pae-SVIVmSnapshotMOID".Split(",")
    $Desktop = Get-QADObject -Service $ConnectionServer -DontUseDefaultIncludedProperties -IncludedProperties $arrIncludedProperties -LdapFilter "(&(objectClass=pae-Server)(distinguishedName=$MemberDN))" -SizeLimit 0 | Sort-Object "pae-DisplayName" | Select-Object Name, "pae-DisplayName", "pae-SVIVmParentVM" , "pae-SVIVmSnapshot", "pae-SVIVmSnapshotMOID"

    Return $Desktop
}

$DesktopExceptions = @()
$pools = Get-Pools -ConnectionServer $ConnectionServer

ForEach($pool in $pools)
{
    $MemberDNs = $pool.memberdn
    ForEach($MemberDN in $MemberDNs)
    {
        $Desktop = Get-Desktop -MemberDN $MemberDN -ConnectionServer $ConnectionServer
        If($Desktop."pae-SVIVmSnapshotMOID" -ne $pool.SVIVmSnapshotMOID)
        {
            $obj = New-Object PSObject -Property @{
                "PoolName" = $pool.DisplayName
                "DisplayName" = $Desktop."pae-DisplayName"
                "PoolSnapshot" = $pool.SVIVmSnapshot
                "PoolSVIVmSnapshotMOID" = $pool.SVIVmSnapshotMOID
                "DesktopSVIVmSnapshot" = $Desktop."pae-SVIVmSnapshot"
                "DesktopSVIVmSnapshotMOID" = $Desktop."pae-SVIVmSnapshotMOID"
                "DesktopDN" = $MemberDN }
            $DesktopExceptions += $obj
        }
    }
}

If($DesktopExceptions -eq $null)
{
    Write-Output "All desktops in $pool are currently using the correct snapshots." | Out-File -Append $log
}
Else
{
    Write-Output $DesktopExceptions | Select-Object DisplayName,PoolName,PoolSnapshot,DesktopSVIVmSnapshot | Out-File -Append $log
}
