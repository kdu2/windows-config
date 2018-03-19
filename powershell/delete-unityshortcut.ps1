param($shortcut="Unity")
$users = Get-ChildItem -Path c:\users -Directory
foreach ($user in $users) { Get-ChildItem -File "C:\users\$($user.name)\Desktop" | where { $_.name -like "$shortcut*" } | Remove-Item -Force }
