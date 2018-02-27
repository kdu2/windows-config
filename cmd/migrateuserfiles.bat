@echo off
echo "migrating local user files to \\occ-profiles\Profiles\%username%"
echo "copying Desktop folder..."
robocopy "%userprofile%\Desktop" "\\occ-profiles\Profiles\%username%\Desktop" /mir /copy:dat /r:2 /w:5 /xo /mt:4 /tee /xf .tmp thumbs.db ~.*
echo "copying Documents folder..."
robocopy "%userprofile%\Documents" "\\occ-profiles\Profiles\%username%\Documents" /mir /copy:dat /r:2 /w:5 /xo /mt:4 /tee /xf .tmp thumbs.db ~.*
echo "copying Downloads folder..."
robocopy "%userprofile%\Downloads" "\\occ-profiles\Profiles\%username%\Downloads" /mir /copy:dat /r:2 /w:5 /xo /mt:4 /tee /xf .tmp thumbs.db ~.*
echo "copying Favorites folder..."
robocopy "%userprofile%\Favorites" "\\occ-profiles\Profiles\%username%\Favorites" /mir /copy:dat /r:2 /w:5 /xo /mt:4 /tee /xf .tmp thumbs.db ~.*
echo "file migration complete"
pause
