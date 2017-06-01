cd %~dp0
python-3.6.1-amd64.exe /passive InstallAllUsers=1 PrependPath=1 CompileAll=1 TargetDir=C:\Python36
REM pip install package.whl
REM easy_install package.egg
setx /m PYTHONPATH C:\Python36
setx /m PYTHONPATH C:\Python36\scripts
pause