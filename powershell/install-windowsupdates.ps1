# install windows patches

<#
$computers = Get-Content -Path C:\Computers.txt
foreach ($computer in $computers) {
    Invoke-Command -ComputerName WSUSSERVER -ScriptBlock { Add-WsusComputer -Computer $using:computer -TargetGroupName 'Group Here' }
    Install-WindowsUpdate -ComputerName $computer
}
#>

WorkFlow Install-Patches {
    param ($computers)
    ForEach -parallel ($computer in $computers) {
        "Running patching job for $($computer.name)"
         Install-WindowsUpdate -ComputerName $computer.name -ForceReboot
    }
}

Import-Module windowsupdate -force
Install-Patches -computers (Get-ADComputer -filter {name -like "*-DC*"})
