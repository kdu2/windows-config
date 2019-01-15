param(
    [string]$passwordfile="\\server\share\local.txt",
    [string]$keyfile="\\server\share\aes.key"
)

$key = Get-Content $keyfile
$password = Read-Host -AsSecureString -Prompt "Enter a password"
$password | ConvertFrom-SecureString -key $key | Out-File $passwordfile
