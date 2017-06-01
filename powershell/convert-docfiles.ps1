# convert files from doc to docx
param([string]$folderpath)

[ref]$SaveFormat = "microsoft.office.interop.word.WdSaveFormat" -as [type]
$word = New-Object -ComObject word.application
$word.visible = $false
$fileType = "*doc"

if ($folderpath -eq "") {
    Write-Host "no path specified"
    exit
}

Get-ChildItem -path $folderpath -include $fileType | foreach-object { 
    $path = ($_.fullname).substring(0,($_.FullName).lastindexOf("."))
    "Converting $path.doc to docx"
    $doc = $word.documents.open($_.fullname)
    $doc.saveas([ref] $path, [ref]$SaveFormat::wdFormatDocumentDefault)
    $doc.close()
}

$word.Quit()
$word = $null
[gc]::collect()
[gc]::WaitForPendingFinalizers()
