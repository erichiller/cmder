@ECHO OFF
:: Quick script to push your public key to the far server // easy ssh logins
IF [%1] == [] GOTO :help
IF %1 == -h GOTO :help
if %1 == --help GOTO :help
if %1 == -? GOTO :help

cat ~/.ssh/id_rsa.pub | ssh %1 "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"

::rem success now exit
GOTO:eof

:help
echo -------------------------------------------------------------------------------
echo SSH PUBLIC KEY PUSH SCRIPT - help
echo 	Please enter username@hostname that you would like your public key pushed to
echo 	#Your public key will be taken from ~/.ssh/id_rsa.pub
echo 	#(That is your Windows Home Directory)
echo ----------------------Eric Hiller-----October 17 2015-------------------------
:: hooray for unnecessary scripts
