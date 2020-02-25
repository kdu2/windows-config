# add list of printers
param([string]$server,[int]$start,[int]$end)
for ($i = $start; $i -le $end; $i++) {
    $printer = $i.ToString()
    Add-Printer -ConnectionName \\$server\$printer
}

Write-Host "Verify printers and drivers have been loaded." #Then press any key to continue."
#[void][System.Consle]::ReadKey($true)
Read-Host -Prompt "Press Enter to continue."

for ($i = $start; $i -le $end; $i++) {
    $printer =  Get-Printer -Name $i.ToString()
    Remove-Printer -InputObject $printer
}
