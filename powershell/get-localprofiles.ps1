# list local user profiles

$excludedprofiles = @(
    "Administrator*"
    "Public"
)

$computer = Read-Host -Prompt "Enter computer name to check for local profiles"

Get-ChildItem -Path "\\$computer\c$\users" | Where-Object {$excludedprofiles -notcontains $_.Name}

