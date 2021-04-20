Push-Location $env:userprofile\github\vsnotes
$gstat = git status --porcelain
if ($gstat.length -ne 0) {
    git add --all
    git commit -m "$gstat"
    git pull
    git push origin main
}
Pop-Location
