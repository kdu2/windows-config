# get parent vm's of desktop pools
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
            "SVIVmParentVM" = $pool."pae-SVIVmParentVM"[0] | Split-Path -Leaf
            "SVIVmSnapshot" = $pool."pae-SVIVmSnapshot"[0] | Split-Path -Leaf
            "SVIVmSnapshotMOID" = $pool."pae-SVIVmSnapshotMOID"[0]
        }
        $PoolList += $obj
    }
    return $PoolList
}

if ($ConnectionServer -ne $null) {
    $pools = Get-Pools -ConnectionServer $ConnectionServer
    $pools | select name,svivmparentvm
} else {
    Write-Host "`$ConnectionServer is blank. Please re-run script with valid parameter."
}
