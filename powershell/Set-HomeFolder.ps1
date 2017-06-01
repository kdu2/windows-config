# change logon script for users based on OU

# input parameter is user OU in LDAP format. e.g. "OU=Path,DC=Domain"
param([string]$OU,[string]$path,[string]$drive)

# set prefix OU
$fullOU = "OU=" + $OU + ",OU=Path,DC=Domain"

Get-ADUser -Filter * -SearchBase $fullOU | foreach-object{
    
    # form full path
    $userpath = $path + "$($_.samaccountname)"
    
    # set path and drive
    Set-ADUser $_.samaccountname -HomeDirectory $userpath -HomeDrive $drive
    
    # clear settings
    #Set-ADUser $_.samaccountname -Clear HomeDrive, HomeDirectory
    
    <#
    # create folder if it doesn't exist
    if(!(Test-Path $userpath))
    {
        mkdir $userpath
    }
    
    # set user
    $usersam = "Domain\$($_.samaccountname)"

    # create permissions
    $FileSystemAccessRights = [System.Security.AccessControl.FileSystemRights]"FullControl"
    $InheritanceFlags = [System.Security.AccessControl.InheritanceFlags]::"ContainerInherit", "ObjectInherit"
    $PropagationFlags = [System.Security.AccessControl.PropagationFlags]::None
    $AccessControl =[System.Security.AccessControl.AccessControlType]::Allow
    $NewAccessrule = New-Object System.Security.AccessControl.FileSystemAccessRule($usersam, $FileSystemAccessRights, $InheritanceFlags, $PropagationFlags, $AccessControl)
 
    # apply permissions
    $currentacl = Get-Acl -Path $userpath
    $currentACL.SetAccessRule($NewAccessrule)
    Set-Acl -path $userpath -AclObject $currentacl
    #>
}
