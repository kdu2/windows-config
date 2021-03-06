<#
.SYNOPSIS
    This Script helps assign Office 365 Licenses to new Students, Faculty, and Staff.
    As well as CAN assign PowerBI (FREE), and can be modified to add other SKUs, and
    logic in the future.
.DESCRIPTION
    Prior to first RUN please create an Office 365 Log with the following command:
        
        New-EventLog -LogName Application -Source "Office 365 Log"

    Then run the script manually as administrator to allow it to create
    necessary files interactively.

    Once all this has been accomplished we can then configure a trigger
    based scheduled task for syncing.  Running "Start-ADSyncSyncCycle"
    on trigger condition.
.PARAMETER Debug
    Enables Debug logging to console
.INPUTS
    None
.OUTPUTS
    Credentials file stored in current folder: $currentuser_azlicense.txt
.NOTES
    Original Author: dgorman
    Maintainer:      kdu2
    Creation Date:   3/20/2020
    Changelog:
        1.0 - dgorman
            Purpose/Change: Initial script development
        1.1 - dgorman
            Initial Release, accepts a Student and/or Employee SKU.
        1.2 - kdu2
            Script formatting cleanup
            Rewrote debug output with switch parameter
            Add parameter splatting for long lines
        1.3 - kdu2
            Switch from MSOnline to AzureAD module
            Use SplitPipeline module for parallelization
.EXAMPLE
    Run script normally
    
    .\Assign-0365License.ps1 
.EXAMPLE
    Run script with debugging enabled

    .\Assign-O365License.ps1 -Debug
#>

param(
    [switch]$Debug
)

#Import-Module MSOnline
Import-Module AzureAD
Import-Module SplitPipeLine
###  Script Behavior / Setup ###
##   Default Error Handling Behavior
$errorActionPreference = "Stop"

## DEBUG
if ($Debug) { $DebugPreference = "Continue" }
# Script Path Variable
$strScriptPath = Split-Path -parent $MyInvocation.MyCommand.Definition

## UserName and password *MUST* be entered on first run!!
$strCurrUser = $env:UserName #User Calling the Script
$strUserName = "admin@domain.com" #Azure User

# -- DO NOT TOUCH BELOW --
# File holding Secure String password for Azure Login
$strPasswordFile = $strCurrUser+"_azlicense.txt"
$strSvcDir = $strScriptPath
# File holding password of User calling this script (used to setup service)
$strPassFile = $strSvcDir +"\" + $strPasswordFile 
# **************************

### License Options ###
## SKUs ##
# Student, unlimited
$strLicenseStudentSku = "STUDENT_SKU" # change to your student sku
# Faculty / Staff, unlimited
$strLicenseEmployeeSku = "STAFF_SKU" # change to your faculty/staff sku
# Power BI Free, unlimited
$strLicensePowerBISku = "POWER_BI_STANDARD" # change to PowerBI sku

<# Script Options #>
# Apply to all users! CAUTION - wipes all individual licenses!
$blnApplyAll = $false
# Assign Power BI (free) to Staff
$blnPowerBItoStaff = $false
# Assign Power BI (free) to Student
$blnPowerBItoStudent = $false
# Interval to break commands in to, as to reduce impact of lost connections.
$intDisplayUsers = 200
###
# Before you can assign a license to a user, you must set the Usage Location
# for the user.  This is represented by the two-character ISO code for that
# region. e.g. US
###
# User Locale
$strUsageLocation = "US"  
# Student License options - The below are DISABLED. adjust for your needs
$StudentLOItems = @(
    "AAD_BASIC_EDU"
    "SCHOOL_DATA_SYNC_P1"
    "STREAM_O365_E3"
    "TEAMS1"
    "INTUNE_O365"
    "Deskless"
    "FLOW_O365_P2"
    "POWERAPPS_O365_P2"
    "RMS_S_ENTERPRISE"
    "OFFICE_FORMS_PLAN_2"
    "PROJECTWORKMANAGEMENT"
    "SWAY"
    "YAMMER_EDU"
    "EXCHANGE_S_STANDARD"
    "MCOSTANDARD"
)

# Staff License Options - The below are DISABLED. adjust for your needs
$StaffLOItems = @(
    "AAD_BASIC_EDU"
    "SCHOOL_DATA_SYNC_P1"
    "STREAM_O365_E3"
    "INTUNE_O365"
    "Deskless"
    "FLOW_O365_P2"
    "POWERAPPS_O365_P2"
    "RMS_S_ENTERPRISE"
    "OFFICE_FORMS_PLAN_2"
    "PROJECTWORKMANAGEMENT"
    "SWAY"
    "YAMMER_EDU"
    #"EXCHANGE_S_STANDARD"
    "MCOSTANDARD"
)

# Assign Student Licenses to Student Domain
# Assume ALL other domains are employee
$strStudentDomain = "student.domain.com" # change to your domain

### Script Start ###
#Write-Debug "** DEBUG is ON! **"

Write-Debug "Checking Directory ${strSvcDir}..."
## If output directory doesn't exist - create!
if (!(Test-Path $strSvcDir)) {
    Write-Debug "`t .. Creating $strSvcDir"
    New-Item -Path $strSvcDir -ItemType Directory
}

## If Password file doesn't exist - create!
Write-Debug "Checking Password File: $strPassfile"
while (!(Test-Path $strPassFile)) {
    Write-Debug "`t .. Creating Password file"
    Read-Host -Prompt "Please enter password for ${strUserName}" -AsSecureString |
        ConvertFrom-SecureString | Out-File $strPassFile
}

## Get password from file
Write-Debug "Creating Credential from $strPassFile"
$password = Get-Content $strPassFile | ConvertTo-Securestring

## Create credential
Write-Debug "Creating Credential for $strUserName"
$cred = New-Object -TypeName System.Management.Automation.PSCredential($strUserName, $password)

try {
    Write-Debug "Connecting to O365"
    Write-Debug "`t.. Importing Modules"
    # Attempts to connect to Office 365 and install Modules
    Import-Module MSOnline  # Load O365 PS module
    Write-Debug "`t.. Sending Credentials"
    # Connect to Service - Office 365
    #Connect-MsolService -Credential $cred -ErrorAction Stop
    Connect-AzureAD -Credential $cred -ErrorAction Stop

    # omitting Exchange items - noted for future script
    <#
    $session = @{
        ConfigurationName = "Microsoft.Exchange"
        ConnectionUri = "https://outlook.office365.com/powershell-liveid/"
        Credential = $cred
        Authentication = "Basic"
    }
    $ExchangeSession = New-PSSession @session -AllowRedirection
    Import-PSSession -AllowClobber $ExchangeSession | Out-Null
    #>
} catch [Microsoft.Online.Administration.Automation.MicrosoftOnlineException] {
    # Logs error for incorrect password
    Write-Host "Please verify your username and password"
    <#
    $TempEventLog = @{
        LogName = "Application"
        Source = "Office 365 Log"
        EntryType = Error
        EventId  = 1
        Message = "OFFICE 365 AUTOMATIC LICENSE ASSIGNMENT`n`nError Connecting to Office 365! Please verify your user name and password"
    }
    Write-EventLog @TempEventLog
    #>
    exit
} catch {
    # Log for any other error
    Write-Host "Error Connecting"
    $TempEventLog = @{
        LogName = "Application"
        Source = "Office 365 Log"
        EntryType = "Error"
        EventId = 1
        Message = "OFFICE 365 AUTOMATIC LICENSE ASSIGNMENT`n`nError Connecting to Office 365!"
    }
    Write-EventLog @TempEventLog
    exit
}

Write-Debug "Starting MAIN Logic"

# Write Event Log - Flag Set
$blnFound = $False
$strOffLog = ""

### Script Logic - 0 - Get All Users ###

if ($blnApplyAll) {
    Write-Host "Retrieving ALL Users..."
    #$usersAll = Get-MsolUser -All
    $usersAll = Get-AzureADUser -All
    Write-Host "... done."
    $intTotalCount = $usersAll.count
    Write-Host "** Retrieved $intTotalCount ALL Users **"
} else {
    Write-Host "Retrieving all Unlicensed Users..."
    #$usersAll = Get-MsolUser -All -UnlicensedUsersOnly
    $usersAllTemp = Get-AzureAdUser
    $usersAll = @()
    foreach ($user in $usersAllTemp) {
        $licensed = $false
        for ($i=0; $i -le ($_.AssignedLicenses | Measure-Object).Count ; $i++) {
            if ( [string]::IsNullOrEmpty(  $_.AssignedLicenses[$i].SkuId ) -ne $True) {
                $licensed = $true
                continue
            }
            if ($licensed -eq $false) {
                $usersAll += $_
        }
    }
    Write-Host "... done."
    $intTotalCount = $usersAll.count
    Write-Host "** Retrieved $intTotalCount Unlicensed Users **"
}

### Student Logic - 1 - Get Users ###

Write-Debug "`tStarting Student Run"
# Clean input
# Trim and Lower case Student Domain to Normalize
$strStudentDomain = $strStudentDomain.replace(" ","").toLower()
Write-Debug "`t`t.. doing query for domain: $strStudentDomain"
# Get Students that are not disabled and need a license
$strDomQuery = "*@" + $strStudentDomain
Write-Host "Starting to sort $strStudentDomain users from All Users ..."
$usersStudents = $usersAll | Where-Object { $_.UserPrincipalName.toLower().replace(" ","") -like $strDomQuery }
Write-Host "... done."

### Student Logic - 2 - Check Users ###

$intTotalCount = $usersStudents.count
Write-Host "** Sorted $intTotalCount Student Users **"
Write-Debug "`t`t.. found $intTotalCount students"
#Write-Host "Starting to sort $strStudentDomain users from All Users ..."
#$displayname = $usersStudents | Select-Object DisplayName | Format-Table -HideTableHeaders | Out-String

if ($usersStudents.count -gt 0) {

    ### Student Logic - 3 - Assign Users ###

    # Assigns usage location
    # Assign license and write log
    Write-Debug "`t`t.. Generating License Options for Student!"
    
    #$StudentLO = New-MsolLicenseOptions -AccountSkuId $strLicenseStudentSku -DisabledPlans $StudentLOItems
    
    if ($Debug) {
        Write-Debug "`t`t.. WOULD assign location: $strUsageLocation"
        Write-Debug "Would assign SKU: $strLicenseStudentSku"
        Write-Debug "Would Disable License Options: $StudentLOItems"
        Write-Debug "Would assign to:"
        foreach ($student in $usersStudents) { Write-Debug "`t $($student.DisplayName)" }
    } else {
        $intDisplayTotalUsers = $usersStudents.count
        <#
        $intRuns = [math]::ceiling( $usersStudents.count / $intDisplayUsers )
        Write-Host "** It will take $intRuns RUNS of $intDisplayUsers to do $intDisplayTotalUsers Users!"
        for ($i = 1; $i -le $intRuns; $i++) {
            Write-Host "`t Starting Run $i of $intRuns"
            $intStart = ($i - 1) * $intDisplayUsers
            if ($i -eq $intRuns) {
                $intEnd =$usersStudents.count - 1
            } else {
                $intEnd = ($i * $intDisplayUsers) - 1
            }
            if (@($usersStudents[$intStart .. $intEnd]).count -eq 0) {
                $usersStudents | Set-MsolUser -UsageLocation $strUsageLocation -ErrorAction continue
                $usersStudents | Set-MsolUserLicense -AddLicenses $strLicenseStudentSku -LicenseOptions $StudentLO -ErrorAction continue
            } else {
                $usersStudents[$intStart .. $intEnd] | Set-MsolUser -UsageLocation $strUsageLocation -ErrorAction continue
                $usersStudents[$intStart .. $intEnd] | Set-MsolUserLicense -AddLicenses $strLicenseStudentSku -LicenseOptions $StudentLO -ErrorAction continue
            }
            if ($blnPowerBItoStudent) {
                if (@($usersStudents[$intStart .. $intEnd]).count -eq 0) {
                    $usersStudents | Set-MsolUserLicense -AddLicenses $strLicensePowerBISku
                } else {
                    ### Student Logic - 5 - Power BI? ###
                    $usersStudents[$intStart .. $intEnd] | Set-MsolUserLicense -AddLicenses $strLicensePowerBISku
                }
            }
            #$usersStudents | Set-MsolUserLicense -AddLicenses $strLicenseStudentSku -LicenseOptions $StudentLO
        }
        #>
        $License = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicense
        $LicenseSku = Get-AzureADSubscribedSku | Where-Object { $_.SkuPartNumber -eq $strLicenseStudentSku }
        $License.SkuId = $LicenseSku.SkuID
        $DisabledPlans = $LicenseSku.ServicePlans | ForEach-Object { $_ | Where-Object { $StudentLOItems -contains $_.ServicePlanName} }
        $License.DisabledPlans = $DisabledPlans.ServicePlanId
        $LicensesToAssign = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
        $LicensesToAssign.AddLicenses = $License
        $usersStudents | Split-Pipeline -Count 4 { process { Set-AzureADUserLicense -AssignedLicenses $LicensesToAssign } }
    }

    ### Student Logic - 6 - Log ###

    $blnFound = $True
    if ($Debug) {
        $strOffLog = "[DEBUG-Student] OFFICE 365 AUTOMATIC LICENSE ASSIGNMENT`n`nTotal License's assigned: $intTotalCount`nUser's Assigned: $displayname`n`n"
    } else {
        $strOffLog = "[Student] OFFICE 365 AUTOMATIC LICENSE ASSIGNMENT`n`nTotal License's assigned: $intTotalCount`nUser's Assigned: $displayname`n`n"
    }
}

## Clear array (save memory)
$usersStudents = $null

### Non-Student Logic - 1 - Get Users ###

Write-Debug "`tStarting Fac/Staff Run"
# Get all Domains in Tenant
Write-Debug "`t`t.. getting Domains"
#$strADomainNames = (Get-MsolDomain | Select-Object Name,Status)
$strADomainNames = Get-AzureADDomain | Select-Object Name,Status
foreach ($strDom in $strADomainNames) {
    # Clean input & Create a blank object to store results
    $usersFacStaff = $null
    $strDomName = $strDom.Name.replace(" ","").toLower()
    Write-Debug "`t`t.. Checking Domain: $strDomName"
    if ($strDomName -ne $strStudentDomain -and $strDom.Status -eq "Verified") {
        Write-Debug "`t`t.. Initializing FacStaffArray - $strDomName"
        # Get Staff that are not disabled and need a license
        $strDomQuery = "*@" + $strDomName
        Write-Host "STAFF: Checking $strDomQuery"
        $usersFacStaff = $usersAll | Where-Object { $_.UserPrincipalName.toLower().replace(" ","") -like $strDomQuery }

        ## NEW CODE START August 2017
        ### Non-Student Logic - 2 - Check Users ###

        $intUsersInDomain = $usersFacStaff.count
        if ($intUsersInDomain -gt 0) {
            Write-Host "`t ... Found $intUsersInDomain !"
            $intTotalCount += $usersFacStaff.count
            #$displayname = $usersFacStaff | Select-Object DisplayName | Format-Table -HideTableHeaders | Out-String

            ### Non-Student Logic - 3 - Assign Users ###

            # Assigns usage location
            Write-Debug "`t`t.. WOULD assign location: $strUsageLocation"
            Write-Debug "`t`t.. Generating License Options for Staff!"
            #$StaffLO = New-MsolLicenseOptions -AccountSkuId $strLicenseEmployeeSku -DisabledPlans $StaffLOItems

            if ($Debug) {
                Write-Debug "Would assign SKU: $strLicenseEmployeeSku"
                Write-Debug "Would Disable License Options: $StaffLOItems"
                Write-Debug "Would assign to:"
                foreach ($FacStaffUser in $usersFacStaff) { Write-Debug "`t $($FacStaffUser.DisplayName)" }
            } else {
                <#
                $intRuns = [math]::ceiling( $intUsersInDomain / $intDisplayUsers )
                Write-Host "** It will take $intRuns RUNS of $intDisplayUsers to do $intUsersInDomain Users!"
                for ($i = 1; $i -le $intRuns; $i++) {
                    Write-Host "`t Starting Run $i of $intRuns"
                    $intStart = ($i - 1) * $intDisplayUsers
                    if ($i -eq $intRuns) {
                        $intEnd = $usersFacStaff.count - 1
                    } else {
                        $intEnd = ($i * $intDisplayUsers) - 1
                    }
                    if ($Debug) { foreach ($FacStaffUser in $usersFacStaff) { Write-Debug "`t $($FacStaffUser.DisplayName)" } }
                    if (@($usersFacStaff[$intStart .. $intEnd]).count -eq 0) {
                        $usersFacStaff | Set-MsolUser -UsageLocation $strUsageLocation -ErrorAction continue
                        $usersFacStaff | Set-MsolUserLicense -AddLicenses $strLicenseEmployeeSku -LicenseOptions $StaffLO -ErrorAction continue
                    } else {
                        $usersFacStaff[$intStart .. $intEnd] | Set-MsolUser -UsageLocation $strUsageLocation -ErrorAction continue
                        $usersFacStaff[$intStart .. $intEnd] | Set-MsolUserLicense -AddLicenses $strLicenseEmployeeSku -LicenseOptions $StaffLO -ErrorAction continue
                    }
                    if ($blnPowerBItoStaff) {
                        ### Non-Student Logic - 5 - Power BI? ###
                        if (@($usersFacStaff[$intStart .. $intEnd]).count -eq 0) {
                            $usersFacStaff | Set-MsolUserLicense -AddLicenses $strLicensePowerBISku
                        } else {
                            $usersFacStaff[$intStart .. $intEnd] | Set-MsolUserLicense -AddLicenses $strLicensePowerBISku
                        }
                    }
                }
                #>
                $License = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicense
                $LicenseSku = Get-AzureADSubscribedSku | Where-Object { $_.SkuPartNumber -eq $strLicenseEmployeeSku }
                $License.SkuId = $LicenseSku.SkuID
                $DisabledPlans = $LicenseSku.ServicePlans | ForEach-Object { $_ | Where-Object { $StaffLOItems -contains $_.ServicePlanName} }
                $License.DisabledPlans = $DisabledPlans.ServicePlanId
                $LicensesToAssign = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
                $LicensesToAssign.AddLicenses = $License
                $usersFacStaff | Split-Pipeline -Count 4 { process { Set-AzureADUserLicense -AssignedLicenses $LicensesToAssign } }
            }

            $blnFound = $True
            if ($Debug) {
                $strOffLog += "[DEBUG-Employee] OFFICE 365 AUTOMATIC LICENSE ASSIGNMENT`n`nTotal License's assigned: $intTotalCount`nUser's Assigned: $displayname"
            } else {
                $strOffLog += "[Employee] OFFICE 365 AUTOMATIC LICENSE ASSIGNMENT`n`nTotal License's assigned: $intTotalCount`nUser's Assigned: $displayname"
            }
            $intTotalCount += $usersFacStaff.count
        }
    }
}

### Write Log ###
if ($blnFound) {
    Write-Debug "Writing Log!"
    <#
    $TempEventLog = @{
        LogName = Application
        Source = "Office 365 Log"
        EntryType = Information
        EventId = 1
        Message = $strOffLog
    }
    Write-EventLog @TempEventLog
    #>
    exit
} else {
    Write-Host "Zero licenses were assigned"
    exit
}
