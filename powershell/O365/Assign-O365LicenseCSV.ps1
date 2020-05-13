# Enable Licensing

# csv is list of upn's with field named emailaddress
param([string]$csv = "C:\csv\test.csv")

Start-Transcript -Path C:\csv\output.txt -Append

Import-Module AzureAD

Connect-AzureAD

$users = Import-Csv -Path $csv

$plan = "SKU" # change to  your sku here

$License = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicense
$LicenseSku = Get-AzureADSubscribedSku | Where-Object { $_.SkuPartNumber -eq $plan }
$License.SkuId = $LicenseSku.SkuID
#$DisabledPlans = $LicenseSku.ServicePlans | ForEach-Object { $_ | Where-Object {$_.ServicePlanName -notin $EnabledPlans } }
#$License.DisabledPlans = $DisabledPlans.ServicePlanId
$LicensesToAssign = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
$LicensesToAssign.AddLicenses = $License

foreach ($user in $users) { Set-AzureADUserLicense -ObjectId $user.EmailAddress -AssignedLicenses $LicensesToAssign }

Stop-Transcript
