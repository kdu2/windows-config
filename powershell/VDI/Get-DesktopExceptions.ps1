<#
.SYNOPSIS
   Get-DesktopExceptions is a script that will locate VMware View Linked Clones that are not using the correct snapshot/image.
.DESCRIPTION
   Get-DesktopExceptions will look in the View LDAP datastore to find the snapshot IDs used by the desktops and the pool.
   It compares these values to find any desktops that do not match the pool.
.PARAMETER ConnectionServer
   The View Connection server that you want to run this script against.
#>

param([string]$ConnectionServer)

if ($ConnectionServer -eq $null) {
    Write-Host "Please re-run the script with a valid argument for Connection Server"
    exit
}

function Get-Pools ($ConnectionServer) {
    $ldap = "LDAP://$ConnectionServer`:389/OU=Server Groups,dc=vdi,dc=vmware,dc=int"
    $root = New-Object System.DirectoryServices.DirectoryEntry $ldap
    $query = new-Object System.DirectoryServices.DirectorySearcher
    $query.searchroot = $root
    $query.Filter = "(&(objectClass=pae-ServerPool))"
    $result = $query.findall()
    $pools = $result.getdirectoryentry()

    $PoolList = @()

    foreach ($pool in $pools) {
        $obj = New-Object PSObject -Property @{
            "cn" = $pool.cn
            "name" = $pool.name
            "DisplayName" = $pool."pae-DisplayName"
            "MemberDN" = $pool."pae-MemberDN"
            "SVIVmParentVM" = $pool."pae-SVIVmParentVM"
            "SVIVmSnapshot" = $pool."pae-SVIVmSnapshot"
            "SVIVmSnapshotMOID" = $pool."pae-SVIVmSnapshotMOID"
        }
        $PoolList += $obj
    }
    return $PoolList
}

function Get-Desktop ($MemberDN, $ConnectionServer) {
    $ldap = "LDAP://$ConnectionServer`:389/OU=Servers,dc=vdi,dc=vmware,dc=int"
    $root = New-Object System.DirectoryServices.DirectoryEntry $ldap
    $query = new-Object System.DirectoryServices.DirectorySearcher
    $query.searchroot = $root
    $query.Filter = "(&(objectClass=pae-VM)(distinguishedName=$MemberDN))"
    $result = $query.findone()
    $Desktop = $result.getdirectoryentry()

    return $Desktop
}

$DesktopExceptions = @()

$pools = Get-Pools -ConnectionServer $ConnectionServer
foreach ($pool in $pools) {
    $poolname = $pool.name
    $MemberDNs = $pool.memberdn
    foreach ($MemberDN in $MemberDNs) {
        $Desktop = Get-Desktop -MemberDN $MemberDN -ConnectionServer $ConnectionServer
        $desktopname = $Desktop."pae-DisplayName"
        Write-Host "checking $poolname/$desktopname"
        if ($Desktop."pae-SVIVmSnapshotMOID" -ne $pool.SVIVmSnapshotMOID) {
            $obj = New-Object PSObject -Property @{
                "PoolName" = $pool.DisplayName[0]
                "DisplayName" = $Desktop."pae-DisplayName"[0]
                "PoolSnapshot" = $pool.SVIVmSnapshot[0]
                "PoolSVIVmSnapshotMOID" = $pool.SVIVmSnapshotMOID[0]
                "DesktopSVIVmSnapshot" = $Desktop."pae-SVIVmSnapshot"[0]
                "DesktopSVIVmSnapshotMOID" = $Desktop."pae-SVIVmSnapshotMOID"[0]
                "DesktopDN" = $MemberDN[0] }
            $DesktopExceptions += $obj
        }
    }
}

if ($DesktopExceptions -eq $null) {
    Write-Host "All desktops are using the correct snapshot."
} else {
    $date = Get-Date -Format "yyyy-MM-dd hh.mm.sstt"
    Write-Output $DesktopExceptions | select DisplayName,PoolName,PoolSnapshot,DesktopSVIVmSnapshot | sort DisplayName | Export-Csv "C:\logs\desktopexceptions-$date.csv" -NoTypeInformation
    Write-Output $DesktopExceptions | select DisplayName,PoolName,PoolSnapshot,DesktopSVIVmSnapshot | sort DisplayName

    $confirm = Read-Host -Prompt "Do you want to recompose detected exceptions? Type `"Recompose`" to confirm."

    if ($confirm -like "recompose") {
        Add-PSSnapin vmware.vimautomation.core
        Add-PSSnapin vmware.view.broker

        $viewpools = Get-Pool

        foreach ($Exception in $DesktopExceptions) {
            Write-Host "Recomposing" $Exception.Displayname
            $currentpool = $viewpools | where { $_.pool_id -eq $Exception.PoolName }
            Get-DesktopVM -Name $Exception.DisplayName | Send-LinkedCloneRecompose -parentVMPath $currentpool.parentVMPath -parentSnapshootPath $currentpool.parentVMSnapshotPath -schedule ((Get-Date).AddMinutes(1)) -ForceLogoff $true -StopOnError $false
        }
    } else {
        Write-Host "Recompose not confirmed. Exiting..."
    }
}
