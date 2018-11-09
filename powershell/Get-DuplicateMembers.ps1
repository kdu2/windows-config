function Get-DuplicateMembers ([string]$groupA,[string]$groupB) {
    if (!(Get-Module ActiveDirectory)) { Import-Module ActiveDirectory }
    $users = (Get-ADGroup -Identity $groupA -Properties *).members
    $duplicateusers = @()
    foreach ($cn in $users) {
        $user = Get-ADUser -Identity $cn -Properties *
        if ($user.memberof -like "CN=$groupB*") {
            $duplicateusers += $user.samaccountname
        }
    }
    if (!(Test-Path C:\logs)) { New-Item -Path C:\logs -ItemType Directory }
    $duplicateusers | Sort-Object | Out-File "c:\logs\duplicateusers.txt"
}
