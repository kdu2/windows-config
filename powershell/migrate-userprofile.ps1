# migrate user profile from old pc to new pc

$destination = "\\location\server\$env:USERNAME\backup"

$folder = "Desktop",
"Downloads",
"Favorites",
"Documents",
"Music",
"Pictures",
"Videos",
"AppData\Local\Mozilla",
"AppData\Local\Google",
"AppData\Roaming\Mozilla"

###############################################################################################################

$username = Get-Content $env:username
$userprofile = Get-Content $env:userprofile
$appData = Get-Content $env:localAPPDATA


###### Restore data section ######
if ([IO.Directory]::Exists($destination + "\" + $username + "\")) 
{ 

    $caption = "Choose Action";
    $message = "A backup folder for $username already exists, would you like to restore the data to the local machine?";
    $Yes = new-Object System.Management.Automation.Host.ChoiceDescription "&Yes","Yes";
    $No = new-Object System.Management.Automation.Host.ChoiceDescription "&No","No";
    $choices = [System.Management.Automation.Host.ChoiceDescription[]]($Yes,$No);
    $answer = $host.ui.PromptForChoice($caption,$message,$choices,0)

    if ($answer -eq 0) 
    {

        Write-Host -ForegroundColor Green "Restoring data to local machine for $username"
        foreach ($f in $folder)
        {   
            $currentLocalFolder = $userprofile + "\" + $f
            $currentRemoteFolder = $destination + "\" + $username + "\" + $f
            Write-Host -ForegroundColor Cyan "  $f..."
            Copy-Item -ErrorAction SilentlyContinue -Recurse $currentRemoteFolder $userprofile

            if ($f -eq "AppData\Local\Mozilla") { Rename-Item $currentLocalFolder "$currentLocalFolder.old" }
            if ($f -eq "AppData\Roaming\Mozilla") { Rename-Item $currentLocalFolder "$currentLocalFolder.old" }
            if ($f -eq "AppData\Local\Google") { Rename-Item $currentLocalFolder "$currentLocalFolder.old" }

        }
        Rename-Item "$destination\$username" "$destination\$username.restored"
        Write-Host -ForegroundColor Green "Restore Complete!"
    }

    else
    {
        Write-Host -ForegroundColor Yellow "Aborting process"
        exit
    }


}

###### Backup Data section ########
else 
{ 

    Write-Host -ForegroundColor Green "Outlook is about to close, save any unsaved emails then press any key to continue ..."

    $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

    Get-Process | Where-Object { $_.Name -Eq "OUTLOOK" } | Kill

    Write-Host -ForegroundColor Green "Backing up data from local machine for $username"

    foreach ($f in $folder)
    {   
        $currentLocalFolder = $userprofile + "\" + $f
        $currentRemoteFolder = $destination + "\" + $username + "\" + $f
        $currentFolderSize = (Get-ChildItem -ErrorAction SilentlyContinue $currentLocalFolder -Recurse -Force | Measure-Object -ErrorAction SilentlyContinue -Property Length -Sum ).Sum / 1MB
        $currentFolderSizeRounded = [System.Math]::Round($currentFolderSize)
        Write-Host -ForegroundColor Cyan "  $f... ($currentFolderSizeRounded MB)"
        Copy-Item -ErrorAction SilentlyContinue -Recurse $currentLocalFolder $currentRemoteFolder
    }



    $oldStylePST = [IO.Directory]::GetFiles($appData + "\Microsoft\Outlook", "*.pst") 
    foreach($pst in $oldStylePST)   
    { 
        if ((Test-Path -Path ($destination + "\" + $username + "\Documents\Outlook Files\oldstyle")) -eq 0){New-Item -Type Directory -Path ($destination + "\" + $username + "\Documents\Outlook Files\oldstyle") | Out-Null}
        Write-Host -ForegroundColor Yellow "  $pst..."
        Copy-Item $pst ($destination + "\" + $username + "\Documents\Outlook Files\oldstyle")
    }    

    Write-Host -ForegroundColor Green "Backup complete!"

}
