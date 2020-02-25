param([string]$fileA,[string]$fileB)

$filehashA = Get-FileHash -Algorithm SHA256 -Path $fileA
$filehashB = Get-FileHash -Algorithm SHA256 -Path $fileB

if ($filehashA.hash -eq $filehashB.hash) {
    Write-Host "files are the same"
} else {
    Write-Host "files are different"
}
