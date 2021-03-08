# compact vhd's that are not in use

$VHDPaths = @(
    '\\server\share'
)

$VHDExclusions = @(
    'template.vhd'
)

foreach ($path in $VHDPaths) {
    $AllUPDs = Get-ChildItem $path -Recurse -Filter *.vhd | Where-Object { $VHDExclusions -NotContains $_.name } | Select-Object -ExpandProperty fullname

    foreach ($UPD in $AllUPDs) {
        New-Item -Name compact.txt -ItemType file -force | Out-Null
        Add-Content -Path compact.txt "select vdisk file= $UPD"
        Add-Content -Path compact.txt "compact vdisk"
        diskpart.exe /S compact.txt
    }
}
