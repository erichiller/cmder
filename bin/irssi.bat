@echo off
setlocal

set dir=%cd%
cd %CMDER_ROOT%/vendor/irssi
irssi.bat

cd %cd%

endlocal