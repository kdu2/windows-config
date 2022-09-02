param(
    [string]$group,
    [string]$server
)

if (!(Get-Module ActiveDirectory)) { Import-Module ActiveDirectory }

Write-Host "Getting enrolled courses"
$courses = Get-ADGroupMember -Identity $adobegroup -Server $server

$users_obj = @()

$cnmatch = "example"

foreach ($course in $courses) {
    Write-Host "Getting enrolled users for $($course.name)"
    $users = (Get-ADGroup -Identity $course -Property members -Server "$($server):3268").members
    foreach ($cn in $users) {
        if ($cn -like "*$cnmatch*") {
            $user = Get-ADUser -Identity $cn -Properties emailaddress,givenname,surname -Server "$($server):3268"
            $user_temp = New-Object PSObject -Property @{
                "Email" = $user.emailaddress
                "FirstName" = $user.givenname
                "LastName" = $user.surname
            }
            $users_obj += $user_temp
        }
    }
}

if (!(Test-Path c:\temp)) { New-Item -ItemType Directory -Path c:\temp }

$users_obj | Sort-Object -Property email -Unique | ConvertTo-Csv -NoTypeInformation | Out-File c:\temp\$group.csv -Encoding ascii
