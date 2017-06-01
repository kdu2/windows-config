param($aduser)

if (($aduser -eq $null) -or ($aduser -eq ''))
    {$aduser = read-host "Enter a username to unlock"}

try {unlock-ADAccount $aduser}

catch {
    write-host "User $aduser was not found. Hit any key to exit."
    $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit
    }

write-host "User $aduser has been unlocked. Hit any key to exit."

$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
exit