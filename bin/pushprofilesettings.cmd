
@ECHO OFF
SETLOCAL ENABLEEXTENSIONS
	

:: Quick script to push your .bashrc and .vimrc to the far server // easy ssh logins
IF [%1] == [] GOTO :help
IF %1 == -h GOTO :help
if %1 == --help GOTO :help
if %1 == -? GOTO :help

cat ~/.bashrc | dos2unix | ssh %1 "cat > ~/.bashrc" >nul 2>&1
cat ~/.vimrc | dos2unix | ssh %1 "cat > ~/.vimrc" >nul 2>&1

echo Please log out and log back in for settings to take effect.

::rem success now exit
GOTO:eof

:help
echo -------------------------------------------------------------------------------
echo PROFILE SETTINGS PUSH SCRIPT - help
echo 	Please enter username@hostname that you would like your settings pushed to
echo 	Your settings (.bashrc and .vimrc) will be taken from ~/.bashrc and ~/.vimrc
echo 	(That is your Windows Home Directory)
echo ----------------------Eric Hiller-----October 24 2015-------------------------
:: hooray for unnecessary scripts

ENDLOCAL