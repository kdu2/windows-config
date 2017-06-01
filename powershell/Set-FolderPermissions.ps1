<#
.SYNOPSIS
Set up a new folder for a faculty member

.DESCRIPTION
This script takes input for a faculty username and which faculty folder to create the faculty folder.
Within the folder, two more folders are created: 
private and submissions. private is set to deny access to students. Instructors can store files there for their class that 
students don't need access to. submissions is used to collect assignments. Students are able to copy files into the folder 
and also create their own folder inside. They cannot view other students' files or folders.

.PARAMETER facultyname
.PARAMETER foldernumber

.EXAMPLE
.\Set-Folderpermissions.ps1
.EXAMPLE
.\Set-Folderpermissions.ps1 user 1
.EXAMPLE
.\Set-Folderpermissions.ps1 -facultyname user -foldernumber 1
#>

# optional arguments for the script. you also can enter them interactively
param([String]$facultyname,[String]$foldernumber)

# ntfs security module for setting permissions
if (!(Get-Module ntfssecurity)) {
    Import-Module \\server\share\tools\NTFSSecurity
}

# check for argument values and take input if they are not set
if (!$facultyname) { $facultyname = Read-Host -Prompt "Enter faculty username" }
if (!$foldernumber) { $foldernumber = Read-Host -Prompt "Select faculty folder (1-6)" }

# working folder path
$facultypath = "\\server\share\faculty$foldernumber\$facultyname"

# initiate variables
$privatefolder = @()
$submissionsfolder = @()

# create the parent folder if it does not exist yet
if (!(Test-Path $facultypath)) {
    Write-Output "Creating new faculty directory at $facultypath" | Out-Host
    New-Item -Path $facultypath -ItemType Directory | Out-Null
}
# set permissions to full control for the user
Add-NTFSAccess -Path $facultypath -Account "domain\user" -AccessRights FullControl

# create the private folder and set permissions to block student access
# inheritance is disabled
if (!(Test-Path $facultypath\private)) {
    Write-Output "Creating new private directory at $facultypath\private" | Out-Host
    $privatefolder = New-Item -Path $facultypath\private -ItemType Directory
}
Write-Output "Setting permissions for private directory (students do not have access to this folder)" | Out-Host
Disable-NTFSAccessInheritance -Path $privatefolder
Remove-NTFSAccess -Path $privatefolder -Account "Builtin\Users" -AccessRights FullControl
Remove-NTFSAccess -Path $privatefolder -Account "Domain\group" -AccessRights FullControl
Add-NTFSAccess -Path $privatefolder -Account "Domain\group" -AccessRights FullControl -AccessType Deny

# create the submissions folder and set permissions to allow students to create folders and copy files
# students do not have access to other students' files
# inheritance is disabled
if (!(Test-Path $facultypath\submissions)) {
    Write-Output "Creating new submissions directory at $facultypath\submissions" | Out-Host
    $submissionsfolder = New-Item -Path $facultypath\submissions -ItemType Directory
}
Write-Output "Setting permissions for submissions directory. Students can copy files into this folder or create their own folder but not view other students' files" | Out-Host
Disable-NTFSAccessInheritance -Path $submissionsfolder
Remove-NTFSAccess -Path $submissionsfolder -Account "Builtin\Users" -AccessRights FullControl
Remove-NTFSAccess -Path $submissionsfolder -Account "Domain\group" -AccessRights FullControl
Add-NTFSAccess -Path $submissionsfolder -Account "Domain\group" -AccessRights Traverse,ListDirectory,CreateFiles,CreateDirectories,WriteAttributes,WriteExtendedAttributes,ReadPermissions -AppliesTo ThisFolderOnly

Write-Output "folder setup completed." | Out-Host
