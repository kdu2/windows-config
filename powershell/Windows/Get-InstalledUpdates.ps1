param(
    [Parameter(Mandatory=$true)]
    [string[]]$list = "localhost",
    [Parameter(Mandatory=$true)]
    [pscredential]$cred
)

Invoke-Command -ScriptBlock { Get-Hotfix } -Credential $cred -ComputerName $list | Select-Object InstalledOn,PSComputerName,Description,HotFixID,InstalledBy | Export-Csv -NoTypeInformation -Path c:\temp\hotfix.csv
