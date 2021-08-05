param([string]$vcenter)

Import-Module vmware.vimautomation.core

if (!$global:defaultVIserver) {
    if (!$vcenter) { $vcenter = Read-Host -Prompt "vCenter IP or FQDN" }
    Connect-VIServer -Server $vcenter -Credential (Get-Credential)
}

$password = Read-Host -AsSecureString -Prompt "New ESXi password"
$bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password)
$esxpassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)

$vmhosts = Get-VMHost

foreach ($vmhost in $vmhosts) {
    $esxcli = Get-EsxCli -VMHost $vmhost -V2
    $IDList = $esxcli.system.account.list.invoke().UserID
    if ($IDList -notcontains "root") {
        Write-Error -Message "User does not exist" -ErrorAction Stop
    }
    $esxargs = $esxcli.system.account.set.CreateArgs()
    $esxargs.id = "root"
    $esxargs.password = "$esxpassword"
    $esxargs.passwordconfirmation = "$esxpassword"

    $output = $esxcli.system.account.set.invoke($esxargs)
    if ($output -eq $true) {
        Get-VIEvent -Entity $vmhost -MaxSamples 1 | Where-Object { $_.fullformattedmessage -match "Password" } | Select-Object UserLogin, Createdtime, Username, Fullformattedmessage | Format-Table -AutoSize
        $hostd = Get-Log -Key hostd -VMHost $vmhost
        $hostd.Entries | Select-String "Password was changed for account" | Select-Object -Last 1
    }
}
