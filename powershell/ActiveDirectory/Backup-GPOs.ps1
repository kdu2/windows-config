$gpos = Get-GPO -Server DC -All

foreach ($gpo in $gpos) {
    Backup-GPO $gpo
}
