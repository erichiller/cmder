:: Init Script for cmd.exe
:: Sets some nice defaults
:: Eric D Hiller
:: 17 April 2016

@FOR /F %%G IN ('%ConEmuDir%\vendor\msys2\usr\bin\cat %ConEmuDir%\config\vendors.json ^| %ConEmuDir%\bin\jq.exe -r ".vendors[].binpath"') DO @CALL :addpath %%G

:: Run FARmanager if present
@if exist "%ConEmuDir%\vendor\farmanager" ( 
	@set "PATH=%ConEmuDir%\vendor\farmanager;%PATH%"
)
:: mingw
@if exist "%ConEmuDir%\vendor\msys2\mingw32\bin" if "%PROCESSOR_ARCHITECTURE%"=="x86" (
		@set "PATH=%ConEmuDir%\vendor\msys2\mingw32\bin;%PATH%"
	)
) else if exist "%ConEmuDir%\vendor\msys2\mingw64\bin" (
	@if NOT "%PROCESSOR_ARCHITECTURE%"=="x86" (
		@set "PATH=%ConEmuDir%\vendor\msys2\mingw64\bin;%PATH%"
	)
)

:: Change the prompt style
:: See http://ss64.com/nt/prompt.html
:: See http://ascii-table.com/ansi-escape-sequences.php
::
:: this is the old one I had->
:: @prompt $E[1;32;40m$P$S$_[$T]$S$G$S

@prompt $E[0;31;40m%username%$S$E[0;36;40m$P$S$E[0;31;40m$$$E[0;32;40m$S

:: Pick right version of clink
@if "%PROCESSOR_ARCHITECTURE%"=="x86" (
    set architecture=86
) else (
    set architecture=64
)

:: Run clink
@"%ConEmuDir%\vendor\clink\clink_x%architecture%.exe" inject --quiet --profile "%USERPROFILE%"

:: Set the title to the current directory
:: later directory changes handled by alias ` cd=cd $*$T title %=c:% `
@title %=c:%

:: Prepare for msys2

:: I do not even know, copypasted from their .bat
@set PLINK_PROTOCOL=ssh
@if not defined TERM set TERM=cygwin

:: Check if msys2 is installed
@if exist "%ConEmuDir%\vendor\msys2" (
    set "MSYS2_ROOT=%ConEmuDir%\vendor\msys2"
)

:: Add svn , vim & other msys2 programs to the path
@if defined MSYS2_ROOT (
	set "PATH=%MSYS2_ROOT%\usr\bin;%PATH%"
	:: define SVN_SSH so we can use git svn with ssh svn repositories
	if not defined SVN_SSH set "SVN_SSH=%MSYS2_ROOT:\=\%\bin\ssh.exe"
)

:: Enhance Path
@set "PATH=%ConEmuDir%\bin;%PATH%"

:: golang setup
@if exist "C:\Go" (
	set "GOROOT=C:\Go"
)

@if exist "%USERPROFILE%\dev\lib\go" (
	set "GOROOT=%USERPROFILE%\dev\lib\go"
)
:: add GOROOT to PATH ; GOROOT can only be added to PATH if checked if defined
@if defined GOROOT (
	set "GOPATH=%USERPROFILE%\dev"
)
:: for whatever reason %GOROOT%\bin only exists when I check if it exists.
@if exist "%GOROOT%\bin" (
	set "PATH=%GOROOT%\bin;%PATH%"
)
@if exist "%GOPATH%\bin" (
	set "PATH=%GOPATH%\bin;%PATH%"
)


:: node , npm setup
::@if exist "%ConEmuDir%\vendor\nodejs" (
::	@set "PATH=%ConEmuDir%\vendor\nodejs;%PATH%;"
::)

:: Add aliases
@doskey /macrofile="%ConEmuDir%\config\aliases"

:: Set home path
@if not defined HOME set HOME=%USERPROFILE%

@call "%ConEmuDir%\scripts\start-ssh-agent.cmd"
::@call PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& 'C:\Users\SE\Desktop\ps.ps1'"


::EXIT FILE
@GOTO:eof

::BEGIN FUNCTIONS

:: start addpath function
:addpath 
@set VendorPathBin=%ConEmuDir%\vendor\%1
@echo ;%PATH%; | C:\Windows\System32\find.exe /C /I ";%VendorPathBin%;" >nul
@if %ERRORLEVEL% EQU 0 (
	:: found in the PATH already, continue, do not re-add
	GOTO:eof
)
:: test if directory exists
@if exist "%VendorPathBin%" (
	:: add to path
	set "PATH=%VendorPathBin%;%PATH%"
)
:: end function
@GOTO:eof