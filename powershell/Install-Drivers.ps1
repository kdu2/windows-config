$ScriptPath = Split-Path -parent $MyInvocation.MyCommand.Definition

$files = get-childitem -path $Scriptpath -recurse -filter *.inf

foreach ($file in $files)
{
    Write-host "Injecting driver $file"
    pnputil -i -a $file.FullName
}
