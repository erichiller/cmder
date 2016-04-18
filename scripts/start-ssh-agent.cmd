@REM Do not use "echo off" to not affect any child calls.

@REM Enable extensions, the `verify` call is a trick from the setlocal help
@VERIFY other 2>nul
@SETLOCAL EnableDelayedExpansion
@IF ERRORLEVEL 1 (
    @ECHO Unable to enable extensions
    @CALL :failure
)
@SET DEBUG=TRUE

@IF "%DEBUG%" == "TRUE" @( @ECHO [DEBUG] ON )

:: Start the ssh-agent if needed by git
@For %%i IN ("git.exe") DO @SET GIT=%%~$PATH:i
@IF "%DEBUG%" == "TRUE" @( @ECHO [DEBUG] GIT=%GIT% )
@IF EXIST "%GIT%" @(
    @REM Get the ssh-agent executable
    @FOR %%i IN ("ssh-agent.exe") DO @SET SSH_AGENT=%%~$PATH:i
	@IF "%DEBUG%" == "TRUE" @( @ECHO [DEBUG] SSH_AGENT=!SSH_AGENT! )
    @IF NOT EXIST "!SSH_AGENT!" @(
		@ECHO [DEBUG] SSH_AGENT EXE file not found
        @CALL :failure
    )
    @REM Get the ssh-add executable
    @FOR %%s IN ("!SSH_AGENT!") DO @SET BIN_DIR=%%~dps
    @FOR /D %%s in ("!BIN_DIR!ssh-add.exe") DO @SET SSH_ADD=%%~s
    @IF NOT EXIST "!SSH_ADD!" @ECHO ssh-add.exe not found
    @IF NOT EXIST "!SSH_ADD!" @CALL :SSHAgentDone
	@REM Check if the agent is running
    @FOR /f "tokens=1-2" %%a IN ('tasklist /fi "imagename eq ssh-agent.exe"') DO @(
        @ECHO %%b | @FINDSTR /r /c:"[0-9][0-9]*" > NUL
        @IF "!ERRORLEVEL!" == "0" @(
            @SET SSH_AGENT_PID=%%b
        ) else @(
			@REM Unset in the case a user kills the agent while a session is open
			@REM needed to remove the old files and prevent a false message
            @SET SSH_AGENT_PID=
        )
    )
	@IF "%DEBUG%" == "TRUE" @( @ECHO [DEBUG] SSH_AGENT_PID=!SSH_AGENT_PID!
    @CALL :TryExistingSocket
	@GOTO:eof
)

:: Check if ssh-agent already started and if so find its socket
:TryExistingSocket
@SET PID_DIR="%ConEmuDir%\vendor\msys2\tmp"
@IF "%DEBUG%" == "TRUE" @( @ECHO [DEBUG] looking for existing socket in %PID_DIR% )
:: Should there be no SSH_AGENT_PID then remove all the ssh-* dirs in /tmp
:: And kill any invalid running ssh-agent processes
@IF [!SSH_AGENT_PID!] == []  @(
	@ECHO Removing old ssh-agent sockets
	@FOR /d %%d IN (%PID_DIR%\ssh-??????*) DO @RMDIR /s /q %%d
	TASKKILL /F /IM "ssh-agent.exe"
) ELSE  @(
	@IF "%DEBUG%" == "TRUE" @( @ECHO [DEBUG] Found ssh-agent PID=!SSH_AGENT_PID! )
	@FOR /d %%d IN (%PID_DIR%\ssh-??????*) DO @(
		@FOR %%f IN (%%d\agent.*) DO @(
			@SET SSH_AUTH_SOCK=%%f
			@IF "%DEBUG%" == "TRUE" @( @ECHO [DEBUG] SOCKET FILE FOUND=%%f )
			@SET SSH_AUTH_SOCK=!SSH_AUTH_SOCK:%PID_DIR%=/tmp!
			@SET SSH_AUTH_SOCK=!SSH_AUTH_SOCK:\=/!
		)
	)
	@IF NOT [!SSH_AUTH_SOCK!] == [] @(
		@IF "%DEBUG%" == "TRUE" @( @ECHO [DEBUG] Found ssh-agent socket=!SSH_AUTH_SOCK! )
	) ELSE (
		@ECHO Failed to find ssh-agent socket
		@SET SSH_AGENT_PID=
	)
)
@REM See if we have the key
@SET "HOME=%USERPROFILE%"
@"!SSH_ADD!" -l 1>NUL 2>NUL
@IF "%DEBUG%" == "TRUE" @( @ECHO [DEBUG] TRYING ADD SSH KEY WITH %SSH_ADD% )
@SET result=!ERRORLEVEL!
@IF NOT !result! == 0 @(
	@IF !result! == 2 @(
		@IF "%DEBUG%" == "TRUE" @( @ECHO [DEBUG] SSH-ADD FAILURE, ERROR CODE=2 )
		@IF NOT [!SSH_AUTH_SOCK!] == [] @(
			@IF "%DEBUG%" == "TRUE" @( @ECHO [DEBUG] KEY ADD FAILED... CALLING FUNCTION:RemoveInvalidSocket SOCK=%SSH_AUTH_SOCK% )
			@CALL :RemoveInvalidSocket
		)
		@ECHO | @SET /p=Starting ssh-agent:
		@FOR /f "tokens=1-2 delims==;" %%a IN ('"!SSH_AGENT!"') DO @(
			@IF NOT [%%b] == [] @SET %%a=%%b
		)

		@ECHO. done
	)
	@IF "%DEBUG%" == "TRUE" @( @ECHO [DEBUG] SSH-ADD TRYING AGAIN... )
	@"!SSH_ADD!"
	@ECHO.
)
@IF "%DEBUG%" == "TRUE" @( @ECHO [DEBUG] SUCCESSFULLY ADDED KEYS TO SSH-AGENT )
@GOTO:eof

:RemoveInvalidSocket
@IF "%DEBUG%" == "TRUE" @( @ECHO [DEBUG] CALLED RemoveInvalidSocket FOR SOCKET=%SSH_AUTH_SOCK% )
@IF EXIST "%SSH_AUTH_SOCK%" @(
	@IF "%DEBUG%" == "TRUE" @( @ECHO [DEBUG] DELETING INVALID SOCKET FILE=%SSH_AUTH_SOCK% )
	@RD /S /q "%SSH_AUTH_SOCK%\..\"
)
@GOTO:eof

:SSHAgentDone
:failure
@IF "%DEBUG%" == "TRUE" @( @echo [DEBUG] FAILURE %BIN_DIR% %SSH_AUTH_SOCK% %SSH_AGENT_PID% )
@ENDLOCAL & @SET "SSH_AUTH_SOCK=%SSH_AUTH_SOCK%" ^
          & @SET "SSH_AGENT_PID=%SSH_AGENT_PID%"

@ECHO %cmdcmdline% | @FINDSTR /l "\"\"" >NUL
@IF NOT ERRORLEVEL 1 @(
    @CALL cmd %*
)
