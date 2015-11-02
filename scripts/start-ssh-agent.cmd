@REM Do not use "echo off" to not affect any child calls.

@REM Enable extensions, the `verify` call is a trick from the setlocal help
@VERIFY other 2>nul
@SETLOCAL EnableDelayedExpansion
@IF ERRORLEVEL 1 (
    @ECHO Unable to enable extensions
    @GOTO failure
)
@SET DEBUG=TRUE

@IF "%DEBUG%" == "TRUE" @( @ECHO [DEBUG] ON )

:: Start the ssh-agent if needed by git
@For %%i IN ("git.exe") DO @SET GIT=%%~$PATH:i
@IF "%DEBUG%" == "TRUE" @( @ECHO [DEBUG] GIT=%GIT% )
@IF EXIST "%GIT%" @(
    @REM Get the ssh-agent executable
    @FOR %%i IN ("ssh-agent.exe") DO @SET SSH_AGENT=%%~$PATH:i
	@IF "%DEBUG%" == "TRUE" @( @ECHO [DEBUG] SSH_AGENT = %SSH_AGENT% )
    IF NOT EXIST "!SSH_AGENT!" @(
		@ECHO [DEBUG] SSH_AGENT EXE file not found
        @GOTO failure
    )
    @REM Get the ssh-add executable
    @FOR %%s IN ("!SSH_AGENT!") DO @SET BIN_DIR=%%~dps
    @FOR /D %%s in ("!BIN_DIR!\ssh-add.exe") DO @SET SSH_ADD=%%~s
    @IF NOT EXIST "!SSH_ADD!" @GOTO ssh-agent-done
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
	@IF "%DEBUG%" == "TRUE" @( @ECHO [DEBUG] SSH_AGENT_PID= %SSH_AGENT_PID%
    GOTO try-existing-socket
)


@REM check if ssh-agent already started and if so find it's socket!
:try-existing-socket
	@SET PID_DIR=%CMDER_ROOT%\vendor\msys2\tmp\
	@IF "%DEBUG%" == "TRUE" @( @ECHO [DEBUG] looking for existing socket in %PID_DIR% )
	@REM if there is no SSH_AGENT_PID then remove all the ssh-* dirs in /tmp
    @IF [!SSH_AGENT_PID!] == []  @(
        @ECHO Removing old ssh-agent sockets
        @FOR /d %%d IN (%PID_DIR%\ssh-??????*) DO @RMDIR /s /q %%d
    ) ELSE  @(
        @IF "%DEBUG%" == "TRUE" @( @ECHO [DEBUG]Found ssh-agent PID=!SSH_AGENT_PID! )
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
    @SET result=!ERRORLEVEL!
    @IF NOT !result! == 0 @(
        @IF !result! == 2 @(
	    @IF "%DEBUG%" == "TRUE" @( @ECHO [DEBUG] CALLING FUNCTION:remove-invalid-socket SOCK=%SSH_AUTH_SOCK% )
	    @CALL:remove-invalid-socket
            @ECHO | @SET /p=Starting ssh-agent:
            @FOR /f "tokens=1-2 delims==;" %%a IN ('"!SSH_AGENT!"') DO @(
                @IF NOT [%%b] == [] @SET %%a=%%b
            )
	    @IF "%DEBUG%" == "TRUE" @( @ECHO [DE2BUG] SUCCESSFULLY CONNECTED TO SSH-AGENT )
            @ECHO. done
        )
	    @IF "%DEBUG%" == "TRUE" @( @ECHO [DE1BUG] SUCCESSFULLY CONNECTED TO SSH-AGENT )
        @"!SSH_ADD!"
        @ECHO.
    )
    @IF "%DEBUG%" == "TRUE" @( @ECHO [DEBUG] SUCCESSFULLY ADDED KEYS TO SSH-AGENT )
@goto:eof

:remove-invalid-socket
@IF "%DEBUG%" == "TRUE" @( @ECHO [DEBUG] CALLED REMOVE-INVALID-SOCKET FOR SOCKET=%SSH_AUTH_SOCK% )
@IF EXIST "%SSH_AUTH_SOCK%" @(
	@IF "%DEBUG%" == "TRUE" @( @ECHO "DELETING INVALID SOCKET FILE=%SSH_AUTH_SOCK%" )
	@RD /S /q "%SSH_AUTH_SOCK%\..\"
	@GOTO:try-existing-socket
)
TASKKILL /F /IM "ssh-agent.exe"
@goto:eof

:ssh-agent-done
:failure
@IF "%DEBUG%" == "TRUE" @( @echo [DEBUG]mark_the end %BIN_DIR% %SSH_AUTH_SOCK% %SSH_AGENT_PID% )
@ENDLOCAL & @SET "SSH_AUTH_SOCK=%SSH_AUTH_SOCK%" ^
          & @SET "SSH_AGENT_PID=%SSH_AGENT_PID%"

@ECHO %cmdcmdline% | @FINDSTR /l "\"\"" >NUL
@IF NOT ERRORLEVEL 1 @(
    @CALL cmd %*
)
