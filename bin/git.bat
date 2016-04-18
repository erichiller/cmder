@echo off
:: NOTE: THIS WILL ONLY WORK FOR REPOs THAT ARE LOCATED IN MSYS2 ACCESSIBLE DIRECTORIES /c/.... STYLE

:: Find root dir
@if not defined ConEmuDir (
    for /f "delims=" %%i in ("%~dp0\..") do @set ConEmuDir=%%~fi
)

:: %~dp0
:: from: http://stackoverflow.com/questions/4419868/what-is-the-current-directory-in-a-batch-file
@set "PATH=%PATH%;%ConEmuDir%\vendor\msys2\usr\bin;"
@call "%ConEmuDir%\vendor\msys2\usr\bin\git.exe" %*

