param([string]$ConnectionServer)

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
            "cn" = $pool.cn[0]
            "name" = $pool.name[0]
            "DisplayName" = $pool."pae-DisplayName"[0]
            "MemberDN" = $pool."pae-MemberDN"[0]
            "ParentVM" = $pool."pae-SVIVmParentVM"[0] | Split-Path -Leaf
            "Snapshot" = $pool."pae-SVIVmSnapshot"[0] | Split-Path -Leaf
            "SnapshotID" = $pool."pae-SVIVmSnapshotMOID"[0]
            "desktoptotal" = $pool."pae-VmMaximumCount"[0]
            "vmprefix" = $pool."pae-VmNamePrefix"[0]
            "multiplesession" = [int]($pool."pae-MultiSessionAllowed"[0]) -eq $true
            "refreshpolicy" = $pool."pae-SVIVmRefreshPolicy"[0].trimstart("type=").trimend(';')
            "logofftimeout" = $pool."pae-OptDisconnectLimitTimeout"[0]
        }
        $PoolList += $obj
    }
    return $PoolList
}

if ($null -ne $ConnectionServer) {
    $pools = Get-Pools -ConnectionServer $ConnectionServer
    #$pools | select name,SVIVmParentVM,SVIVmSnapshot
    $pools | Sort-Object parentvm | Select-Object name,vmprefix,desktoptotal,ParentVM,Snapshot,multiplesession,refreshpolicy,logofftimeout | Export-Csv -Path $PSScriptRoot\DesktopPoolInfo.csv -NoTypeInformation
    $pools | Sort-Object parentvm | Select-Object name,vmprefix,desktoptotal,ParentVM,Snapshot,multiplesession,refreshpolicy,logofftimeout
} else {
    Write-Host "`$ConnectionServer is blank. Please re-run script with valid parameter."
}
