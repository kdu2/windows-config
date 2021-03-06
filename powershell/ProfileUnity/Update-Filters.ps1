# edits Profile Unity filters

[string]$global:servername = ""
$global:prousession = $null

## Login function
function Connect-ProfileUnityServer ([string]$server) {
    ## Ignore-SSL Library Code
    add-type @"
        using System.Net;
        using System.Security.Cryptography.X509Certificates;
        public class TrustAllCertsPolicy : ICertificatePolicy {
            public bool CheckValidationResult(
                ServicePoint srvPoint, X509Certificate certificate,
                WebRequest request, int certificateProblem) {
                return true;
            }
        }
"@
    [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

    ## Get Creds
    if ($server) {
        [string]$global:servername = $server
    } else {
        [string]$global:servername = Read-Host -Prompt 'FQDN of ProfileUnity Server Name'
    }
    $user = Read-Host "Enter Username"
    $pass = Read-Host -AsSecureString "Enter Password"
    $pass2=[Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($pass))

    # Connect to Server
    Invoke-WebRequest https://"$servername":8000/authenticate -Body "username=$user&password=$pass2" -Method Post -SessionVariable session
    $global:prousession = $session
}

## Get All Filters
function Get-ProfileUnityFilters {
    $PUGF = ((Invoke-WebRequest https://"$servername":8000/api/filter -WebSession $prousession).Content) | ConvertFrom-Json
    $PUGF.Tag.Rows
    return $PUGF
}

## Get Filter
function Get-ProfileUnityFilter ([string]$Name) {
    $PUGF = ((Invoke-WebRequest https://"$servername":8000/api/filter -WebSession $prousession).Content) | ConvertFrom-Json
    [string]$configID = $PUGF.Tag.Rows | Where-Object {$_.name -eq $Name} | ForEach-Object {$_.id}
    $configR = ((Invoke-WebRequest https://"$servername":8000/api/filter/"$configID" -WebSession $prousession).Content) | ConvertFrom-Json
    $config = $configR.tag
    return $config
}

## Save Filter
function Set-ProfileUnityFilter ($Filter) {
    Invoke-WebRequest https://"$servername":8000/api/filter -ContentType "application/json" -Method Post -WebSession $prousession -Body ($Filter | ConvertTo-Json -Depth 10)
}

## Login to the PU console
Connect-ProfileUnityServer

## Get Filters
$filters = Get-ProfileUnityFilters

## Set Filter settings
foreach ($PUFilter in $filters) {
    $Currentfilter = Get-ProfileUnityFilter -Name $PUFilter.name
    
    $Currentfilter.MachineClasses =     48   # Desktop, Laptop
    $Currentfilter.OperatingSystems = 1024   # Windows 10 
    $Currentfilter.SystemEvents =        1   # Logon/Logoff
    $Currentfilter.Connections =       116   # RDP, PCOIP, Console, Blast

    Set-ProfileUnityFilter -Filter $Currentfilter
}
