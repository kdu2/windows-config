param(
    [string]$vsnotes="$env:userprofile\vsnotes\journal",
    [int]$year
)
Push-Location -Path $vsnotes

if (!$year) { $year = Read-Host -Prompt "Enter year" }
if (!($year % 4)) { $leapyear = $true }
if (!(Test-Path "$vsnotes\$year")) { New-Item -ItemType Directory -Path "$vsnotes\$year" }

$months = @(
    "01-January"
    "02-February"
    "03-March"
    "04-April"
    "05-May"
    "06-June"
    "07-July"
    "08-August"
    "09-September"
    "10-October"
    "11-November"
    "12-December"
)

foreach ($month in $months) {
    New-Item -ItemType Directory -Path "$vsnotes\$year\$month"
    $mtemp = $month.Substring(3)
    1..9 | ForEach-Object { Write-Output $null >> "$vsnotes\$year\$month\$($mtemp)_0$($_)_$year.md" }
    10..31 | ForEach-Object { Write-Output $null >> "$vsnotes\$year\$month\$($mtemp)_$($_)_$year.md" }
}

if ($leapyear) { Remove-Item -Path "$vsnotes\$year\02-February\February_29_$year.md" -Force }

$extradays = @(
    "02-February\February_30"
    "02-February\February_31"
    "04-April\April_31"
    "06-June\June_31"
    "09-September\September_31"
    "11-November\November_31"
)

foreach ($day in $extradays) { Remove-Item -Path "$vsnotes\$year\$($day)_$year.md" -Force }

Pop-Location
