# This PowerShell script creates a home folder for all users in a specified OU in Active Directory   

# This script has the following functionalities:
# 1 Creates a personal (home folder) for all AD users in an OU
# 2 Grants each users "Full Control" to his or her folder
# 3 Maps the users folder as drive 'S'
# 4 Ensures that users canot access another user's folder

# BEGIN SCRIPT

# input parameters include the target OU and the folder path
param([string]$OU,[string]$path)

# Define variable for a server to use with query.
$ADServer = "DC"

# Import Active Directory Module
Import-Module ActiveDirectory

# define search base - the OU where you want to search for users to modify.
# you can define the domain as your searchbase

# define domain name to use
$Domain = "Domain"

# Append this to the actual OU 
$searchbase = ",OU=Path,DC=Domain"
$searchOU = "OU=$OU" + $searchbase

$fullpath = "\\server\share\$path"

# Search for AD users to modify
$ADUsers = Get-ADUser -server $ADServer -Filter * -searchbase $searchOU -Properties *

ForEach ($ADUser in $ADUsers) 
{

# create new home folder for each user
New-Item -ItemType Directory -Path "$fullpath\users\$($ADUser.DisplayName)"

# Grant each user Full Control to the users home folder only

# Define variables for the access rights

# Define variable for user to grant access (IdentityReference: the user name in Active Directory)
# Usually in the format domain\username or groupname
# Presenting the sAMAccountname in this format stops it displaying in Distinguished Name format
$UsersAm = "$Domain\$($ADUser.sAMAccountname)"

#Define FileSystemAccessRights:identifies what type of access we are defining, whether it is Full Access, Read, Write, Modify

$FileSystemAccessRights = [System.Security.AccessControl.FileSystemRights]"FullControl"

# define InheritanceFlags:defines how the security propagates to child objects by default
# Very important - so that users have ability to create or delete files or folders in their folders
$InheritanceFlags = [System.Security.AccessControl.InheritanceFlags]::"ContainerInherit", "ObjectInherit"

# Define PropagationFlags: specifies which access rights are inherited from the parent folder (users folder).
$PropagationFlags = [System.Security.AccessControl.PropagationFlags]::None

# Define AccessControlType:defines if the rule created below will be an 'allow' or 'Deny' rule
$AccessControl =[System.Security.AccessControl.AccessControlType]::Allow 

#define a new access rule to apply to users folders
$NewAccessrule = New-Object System.Security.AccessControl.FileSystemAccessRule `
    ($UsersAm, $FileSystemAccessRights, $InheritanceFlags, $PropagationFlags, $AccessControl) 

# set acl for each user folder
# define the folder for each user
$userfolder = "$fullpath\users\$($ADUser.DisplayName)"

$currentACL = Get-ACL -path $userfolder
#Add this access rule to the ACL
$currentACL.SetAccessRule($NewAccessrule)
#Write the changes to the user folder
Set-ACL -path $userfolder -AclObject $currentACL

# set variable for homeDirectory (personal folder) and homeDrive (drive letter)
$homeDirectory = "$fullpath\users\$($ADUser.DisplayName)" #This maps the folder for each user 

# set homeDrive for each user
$homeDrive = "S:" #This maps the homedirectory to drive letter S 

# Update the HomeDirectory and HomeDrive info for each user

Set-ADUser -server $ADServer -Identity $ADUser.sAMAccountname -Replace @{HomeDirectory=$homeDirectory}
Set-ADUser -server $ADServer -Identity $ADUser.sAMAccountname -Replace @{HomeDrive=$homeDrive}

}
