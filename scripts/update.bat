:: Update script for EDH-cmder
:: Eric D Hiller
:: 18 April 2016
::
:: run with from the windows run box by pressing WINDOWS KEY + R then entering:
:: cmd.exe /c C:/cmder/scripts/update.bat
::

@echo off

echo Please close conemu
echo Press [ENTER] to continue...
pause

:: Find root dir
if not defined ConEmuDir (
    for /f "delims=" %%i in ("%~dp0\..") do @set ConEmuDir=%%~fi
)

cd %ConEmuDir%
set "PATH=%PATH%;%ConEmuDir%\vendor\msys2\usr\bin;"

taskkill /f /im ssh-agent.exe
taskkill /f /im bash.exe
taskkill /f /im sh.exe
taskkill /f /im powershell.exe

echo If you hadn't closed ConEmu, do so now!
echo Press [ENTER] to continue...

pause

%ConEmuDir%/vendor/msys2/usr/bin/git fetch --all
%ConEmuDir%/vendor/msys2/usr/bin/git reset --hard origin/master
%ConEmuDir%/vendor/msys2/usr/bin/git pull origin master

echo pull complete the next [ENTER] will close the window
pause
taskkill /f /im conhost.exe
taskkill /f /im cmd.exe
