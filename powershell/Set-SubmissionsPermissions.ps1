import-module ActiveDirectory

$folderlist = Get-ChildItem "C:\folder"

$colRights = [System.Security.AccessControl.FileSystemRights]"Traverse, Listdirectory, createfiles, writedata, createdirectories, appenddata, readpermissions, writeattributes, writeExtendedattributes" 
$InheritanceFlag = [System.Security.AccessControl.InheritanceFlags]::None
$PropagationFlag = [System.Security.AccessControl.PropagationFlags]::None
$objType = [System.Security.AccessControl.AccessControlType]::Allow 

# For Choosing a group from ActiveDirectory 
$OU = "OU=Leaf,OU=Path,DC=Domain" 
$Group = (Get-ADGroup -searchbase $OU -filter {name -eq '<group name>'}).sid

# For Choosing a singular user account #$objUser = New-Object System.Security.Principal.NTAccount("<account name>")

$counter = 0

foreach ($folder in $folderlist) {
    $selectedfolder = "\\server\share" + $folderlist[$counter].name
    $objACE = New-Object System.Security.AccessControl.FileSystemAccessRule($Group, $colRights, $InheritanceFlag, $PropagationFlag, $objType)
    $objACL = (Get-Item $selectedfolder).GetAccessControl("Access") $objACL.AddAccessRule($objACE)
    Set-ACL $selectedfolder $objACL
    $counter = $counter + 1
}
