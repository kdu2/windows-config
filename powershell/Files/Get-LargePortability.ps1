
param([string]$profiles="\\server\profiles")

$portability = Get-ChildItem -Path $profiles -Recurse -Include *.7z | Where-Object { $_.Length/1MB -gt 100 }

$archives = @()

foreach ($archive in $portability) {
    $archive_temp = @()
    $archivepath = $archive.fullname.split('\')
    $archive_temp = New-Object PSObject -Property @{
        User = $archivepath[$archivepath.Length - 3]
        File = $archive.name
        Size_MB = ($archive.length/1MB).ToString("0.00")
    }
    
    <#
    $user = $archivepath[$archivepath.Length - 3]
    $archive_temp | Add-Member -MemberType NoteProperty -Name User -Value $user
    $archive_temp | Add-Member -MemberType NoteProperty -Name File -Value $archive.name
    $archive_temp | Add-Member -MemberType NoteProperty -Name Size_MB -Value ($archive.length/1MB).ToString("0.00")
    #>

    $archives += $archive_temp
}

$archives | Export-Csv archives.csv -Force -NoTypeInformation
