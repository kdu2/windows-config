param([string]$keyfile = "\\server\share\aes.key")
$key = new-object byte[] 32
[Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($Key)
$key | Out-File $keyfile
