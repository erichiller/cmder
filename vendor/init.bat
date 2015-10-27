:: Init Script for cmd.exe
:: Sets some nice defaults
:: Created as part of cmder project

:: Find root dir
@if not defined CMDER_ROOT (
    for /f "delims=" %%i in ("%ConEmuDir%\..\..") do @set CMDER_ROOT=%%~fi
)

:: Run FARmanager if present
@if exist "%CMDER_ROOT%\vendor\farmanager" ( 
	@set "PATH=%CMDER_ROOT%\vendor\farmanager;%PATH%"
)

:: Change the prompt style
:: See http://ss64.com/nt/prompt.html
@prompt $E[1;32;40m$P$S$_[$T]$S$G$S

:: Pick right version of clink
@if "%PROCESSOR_ARCHITECTURE%"=="x86" (
    set architecture=86
) else (
    set architecture=64
)

:: Run clink
@"%CMDER_ROOT%\vendor\clink\clink_x%architecture%.exe" inject --quiet --profile "%CMDER_ROOT%\config"




:: Prepare for git-for-windows

:: I do not even know, copypasted from their .bat
@set PLINK_PROTOCOL=ssh
@if not defined TERM set TERM=cygwin

:: Check if git-for-windows is installed
@if exist "%ProgramFiles%\Git" (
    set "GIT_INSTALL_ROOT=%ProgramFiles%\Git"
) else if exist "%ProgramFiles(x86)%\Git" (
    set "GIT_INSTALL_ROOT=%ProgramFiles(x86)%\Git"
) else if exist "%CMDER_ROOT%\vendor" (
    set "GIT_INSTALL_ROOT=%CMDER_ROOT%\vendor\git-for-windows"
)

:: Add git to the path
@if defined GIT_INSTALL_ROOT (
    set "PATH=%GIT_INSTALL_ROOT%\bin;%GIT_INSTALL_ROOT%\usr\bin;%GIT_INSTALL_ROOT%\share\vim\vim74;%PATH%"
    :: define SVN_SSH so we can use git svn with ssh svn repositories
    if not defined SVN_SSH set "SVN_SSH=%GIT_INSTALL_ROOT:\=\\%\\bin\\ssh.exe"
)

:: Enhance Path
@set "PATH=%CMDER_ROOT%\bin;%PATH%;%CMDER_ROOT%"

:: golang setup
@if exist "C:\Go" (
	set "GOROOT=C:\Go"
)
@if exist "%USERPROFILE%\dev\lib\go" (
	set "GOROOT=%USERPROFILE%\dev\lib\go"
	
)
:: add GOROOT to PATH ; GOROOT can only be added to PATH if checked if defined
@if defined GIT_INSTALL_ROOT (
	set "PATH=%USERPROFILE%;%GOROOT%\bin;%PATH%"
	set "GOPATH=%USERPROFILE%\dev"
)
:: node , npm setup
@if exist "%CMDER_ROOT%\vendor\nodejs" (
	@set "PATH=%CMDER_ROOT%\vendor\nodejs;%PATH%;"
)



:: Add aliases
@doskey /macrofile="%CMDER_ROOT%\config\aliases"

:: Set home path
@if not defined HOME set HOME=%USERPROFILE%

@if defined CMDER_START (
    @cd /d "%CMDER_START%"
) else (
    @if "%CD%\" == "%CMDER_ROOT%" (
        @cd /d "%HOME%"
    )
)

@call "%GIT_INSTALL_ROOT%/cmd/start-ssh-agent.cmd"
::@call PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& 'C:\Users\SE\Desktop\ps.ps1'"
