function Get-VMFolderPath {
    foreach ($vm in $Input) {
        $DataCenter = $vm | Get-Datacenter
        $DataCenterName = $DataCenter.Name
        $VMname = $vm.Name
        $VMParentName = $vm.Folder
        if ($VMParentName.Name -eq "vm") {
            $FolderStructure = "{0}\{1}" -f $DataCenterName, $VMname
            $FolderStructure
            Continue
        } else {
            $FolderStructure = "{0}\{1}" -f $VMParentName.Name, $VMname
            $VMParentID = Get-Folder -Id $VMParentName.ParentId
            do {
                $ParentFolderName = $VMParentID.Name
                if ($ParentFolderName -eq "vm") {
                    $FolderStructure = "$DataCenterName\$FolderStructure"
                    $FolderStructure
                    break
                }
                $FolderStructure = "$ParentFolderName\$FolderStructure"
                $VMParentID = Get-Folder -Id $VMParentID.ParentId
            }
            until ($VMParentName.ParentId -eq $DataCenter.Id)
        }
    }
}
