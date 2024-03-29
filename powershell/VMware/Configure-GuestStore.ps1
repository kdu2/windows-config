################################################################################
#
# Copyright (c) 2020 VMware, Inc. All Rights Reserved.
#
# Configure-GuestStore.ps1
#
# PowerCLI script for configuring the GuestStore repository on the hosts
# managed by a vCenter server.
#
# Notes to get started:
# This script is tested with the following Microsoft PowerShell version and
# VMware PowerCLI version:
#
#   PS C:\> $PSVersionTable.PSVersion
#
#   Major  Minor  Build  Revision
#   -----  -----  -----  --------
#   5      1      19041  546
#
#   PS C:\> Get-Module -Name VMware.PowerCLI -ListAvailable
#
#       Directory: C:\Users\TestUser\Documents\WindowsPowerShell\Modules
#
#   ModuleType Version    Name                                ExportedCommands
#   ---------- -------    ----                                ----------------
#   Manifest   12.0.0.... VMware.PowerCLI
#
# All the steps below need to be performed from a Windows system. You can
# skip Step 1 & Step 2 if you have already done so before.
#
# Step 1:
#
# Install VMware PowerCLI in Windows PowerShell.
#
# To uninstall old version of VMware PowerCLI, run:
#
#   PS C:\> (Get-Module -Name VMware.PowerCLI -ListAvailable).RequiredModules | Uninstall-Module -Force
#   PS C:\> Get-Module -Name VMware.PowerCLI -ListAvailable | Uninstall-Module -Force
#
# To install the latest VMware PowerCLI from PowerShell repository 'PSGallery', run:
#
#   PS C:\> Install-Module -Name VMware.PowerCLI -Scope CurrentUser
#
# This installs VMware PowerCLI to the current user directory $home\Documents\PowerShell\Modules.
#
# Note, you don't need to run the script in a PowerShell (Admin) session.
#
# Step 2:
#
# Set Windows PowerShell execution policy:
#
#   PS C:\> Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
#
# Close the current Windows PowerShell window, re-start Windows PowerShell.
#
# Step 3:
#
#   Save this script to a local file, e.g., 'C:\Tool\Configure-GuestStore.ps1'.
#
# Step 4:
#
#   Run this command to set Prompt if the server certificate is not trusted:
#
#   Set-PowerCLIConfiguration -Scope Session -InvalidCertificateAction Prompt
#
# Step 5:
#
#   Sample test commands (Enter empty string to clear repository URL setting and disable GuestStore)
#
#   Configure-GuestStore.ps1 -Server '<VC server name>' -User 'administrator@vsphere.local' -Password '********' \
#                            -Datacenter '<datacenter name>' -ConfigAction get
#
#   Configure-GuestStore.ps1 -Server '<VC server name>' -User 'administrator@vsphere.local' -Password '********' \
#                            -Datacenter '<datacenter name>' -ConfigAction set -Url 'ds:///vmfs/volumes/5bda46e0-08260d5c-3328-d0946644b1a3/GuestStore'
#
#   Configure-GuestStore.ps1 -Server '<VC server name>' -User 'administrator@vsphere.local' -Password '********' \
#                            -Datacenter '<datacenter name>' -ConfigAction set -Url ''
#
#   Configure-GuestStore.ps1 -Server '<VC server name>' -User 'administrator@vsphere.local' -Password '********' \
#                            -Cluster '<cluster name>' -ConfigAction get
#
#   Configure-GuestStore.ps1 -Server '<VC server name>' -User 'administrator@vsphere.local' -Password '********' \
#                            -Cluster '<cluster name>' -ConfigAction set -Url 'ds:///vmfs/volumes/5bda46e0-08260d5c-3328-d0946644b1a3/GuestStore'
#
#   Configure-GuestStore.ps1 -Server '<VC server name>' -User 'administrator@vsphere.local' -Password '********' \
#                            -Cluster '<cluster name>' -ConfigAction set -Url ''
#
#   Configure-GuestStore.ps1 -Server '<VC server name>' -User 'administrator@vsphere.local' -Password '********' \
#                            -HostName '<host name>' -ConfigAction get
#
#   Configure-GuestStore.ps1 -Server '<VC server name>' -User 'administrator@vsphere.local' -Password '********' \
#                            -HostName '<host name>' -ConfigAction set -Url 'ds:///vmfs/volumes/5bda46e0-08260d5c-3328-d0946644b1a3/GuestStore'
#
#   Configure-GuestStore.ps1 -Server '<VC server name>' -User 'administrator@vsphere.local' -Password '********' \
#                            -HostName '<host name>' -ConfigAction set -Url ''
#

[CmdletBinding()]
Param (
   [Parameter(Mandatory = $True,
              HelpMessage = "Enter the vCenter server name or IP.")]
   [ValidateNotNullOrEmpty()]
   [String] $Server,

   [Parameter(Mandatory = $True,
              HelpMessage = "Enter the vCenter server user name.")]
   [ValidateNotNullOrEmpty()]
   [String] $User,

   [Parameter(Mandatory = $True,
              HelpMessage = "Enter the vCenter server user password.")]
   [ValidateNotNullOrEmpty()]
   [String] $Password,

   [Parameter(Mandatory = $False,
              HelpMessage = "Enter the name of the cluster to configure.")]
   [ValidateNotNullOrEmpty()]
   [String] $Cluster,

   [Parameter(Mandatory = $False,
              HelpMessage = "Enter the name of the datacenter to configure.")]
   [ValidateNotNullOrEmpty()]
   [String] $Datacenter,

   [Parameter(Mandatory = $False,
              HelpMessage = "Enter the name of the ESXi host to configure.")]
   [ValidateNotNullOrEmpty()]
   [String] $HostName,

   [Parameter(Mandatory = $False,
              HelpMessage = "Enter the repository URL to set, enter empty string to clear.")]
   [String] $Url = "<null>", # PowerShell always converts $Null to "" for String parameters.
                             # Use "<null>" to represent parameter not provided.
   [Parameter(Mandatory = $True,
              HelpMessage = "'get' or 'set' the GuestStore repository setting.",
              Position=0)]
   [ValidateSet("get", "set")]
   [String] $ConfigAction
)

# Set default cmdlet error action.
$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

Function WriteHostError
{
   Param ([String] $ErrorMessage)

   Write-Host $ErrorMessage -ForegroundColor red -BackgroundColor black
}


Function WriteHostWarning
{
   Param ([String] $WarningMessage)

   Write-Host $WarningMessage -ForegroundColor yellow -BackgroundColor black
}


Function WriteHostAction
{
   Param ([String] $ActionMessage)

   Write-Host $ActionMessage -ForegroundColor green -BackgroundColor black
}

Set-PowerCLIConfiguration -Scope Session -InvalidCertificateAction Ignore -Confirm:$False | Out-Null

if ($DefaultVIServers) {
   $DefaultVIServers | ForEach-Object {Disconnect-VIServer -Server $_ -Force -ErrorAction:SilentlyContinue -confirm:$False}
}

$filterOptionsSpecified = 0

if ($Datacenter) {
   $filterOptionsSpecified++
}

if ($Cluster) {
   $filterOptionsSpecified++
}

if ($HostName) {
   $filterOptionsSpecified++
}

if ($filterOptionsSpecified -eq 0) {
   Write-Host
   WriteHostError "Must specify one of the options: Datacenter, Cluster, HostName"
   Write-Host
   Exit 1
}

if ($filterOptionsSpecified -gt 1) {
   Write-Host
   WriteHostError "Only one of the options: Datacenter, Cluster, HostName is allowed."
   WriteHostError "Multiple options are specified."
   Write-Host
   Exit 1
}

if ($ConfigAction -eq "set") {
   if ($Url -eq "<null>") {
      Write-Host
      WriteHostError "'Url' option not provided."
      Write-Host
      Exit 1
   }
}

Write-Host
Write-Host "Connecting to server $Server..."
Connect-VIServer -Server $Server -User $User -Password $Password -Force
Write-Host "Connected to server $Server."
Write-Host

Function ConfigureGuestStoreInHost($esxHost, $configAction, $Url) {
   $versionElements = $esxHost.Version.Split(".")
   $major = [int] $versionElements[0]
   $minor = [int] $versionElements[1]
   $base = [int] $versionElements[2]

   Write-Host

   if (($major -lt 7) -or
       ($major -eq 7 -and $minor -eq 0 -and $base -lt 2)) {
      WriteHostWarning @"
The version of host $esxHost is '$major.$minor.$base' and is older than the
required minimum version 7.0.2. Skipping configuring this host.
"@
      return
   }

   $esxcli = Get-Esxcli -V2 -VMHost $esxHost
   if ($ConfigAction -eq 'get') {
      WriteHostAction "Retrieving the GuestStore repository setting for host: $esxHost"
      $esxcli.system.settings.gueststore.repository.get.invoke()
   } else {
      WriteHostAction "Setting the GuestStore repository setting for host: $esxHost"
      $arguments = $esxcli.system.settings.gueststore.repository.set.CreateArgs()
      $arguments.url = $Url
      $esxcli.system.settings.gueststore.repository.set.invoke($arguments)
   }
}

if ($Datacenter) {
   try {
      $esxDatacenter = Get-Datacenter -Name $Datacenter
   } catch {
      WriteHostError "Datacenter with name: $Datacenter not found."
      Exit 1
   }
   $esxHosts = $esxDatacenter | Get-VMHost
} elseif ($Cluster) {
   try {
      $esxCluster = Get-Cluster -Name $Cluster
   } catch {
      WriteHostError "Cluster with name: $Cluster not found."
      Exit 1
   }
   $esxHosts = $esxCluster | Get-VMHost
} elseif ($HostName) {
   try {
      $esxHosts = Get-VMHost -Name $HostName
   } catch {
      WriteHostError "Host with name: $HostName not found."
      Exit 1
   }
}

$numEsxHosts = $esxHosts.Length
if ($numEsxHosts -eq 0) {
   WriteHostWarning "No hosts found to configure."
   Exit 0
}

Write-Host "Total number of hosts: $numEsxHosts"
foreach ($esxHost in $esxHosts) {
   ConfigureGuestStoreInHost $esxHost $configAction $Url
}
