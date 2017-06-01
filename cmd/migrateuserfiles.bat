@echo off
echo "migrating local user files to \\server\share\%username%"
echo "copying Desktop folder..."
xcopy /y /e /i /q %userprofile%\Desktop\* \\server\share\%username%\Desktop\
echo "copying Documents folder..."
xcopy /y /e /i /q %userprofile%\Documents\* \\server\share\%username%\Documents\
echo "copying Downloads folder..."
xcopy /y /e /i /q %userprofile%\Downloads\* \\server\share\%username%\Downloads\
echo "copying Favorites folder..."
xcopy /y /e /i /q %userprofile%\Favorites\* \\server\share\%username%\Favorites\
echo "file copy complete"
pause
