@echo off
setlocal

set dir=%cd%
cd %ConEmuDir%/vendor/irssi
irssi.bat

cd %cd%

endlocal