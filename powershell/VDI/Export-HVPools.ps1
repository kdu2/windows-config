Import-Module vmware.hv.helper
$user = Read-Host -Prompt 'Enter username'
$passwd = Read-Host -Prompt 'Enter the password' -AsSecureString
$domain = Read-Host -Prompt 'Enter the domain'
$server = Read-Host -Prompt 'Enter the connection server'
Connect-HVServer -Server $server -Domain $domain -user $user -password $passwd
$pools = (Get-HVPool).base.name

foreach ($pool in $pools) {
    Write-Host 'Export pool',$pool
    Get-HVPool -PoolName $pool | Get-HVPoolSpec -FilePath "C:\temp\poolspecs\$pool.json"
}
