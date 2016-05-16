:: redirect bash to bash from powershell and cmd

:: swap dir formats
@set "t=%~2"
@set t=%t:\=/%

:: Find root dir
@if not defined ConEmuDir (
    for /f "delims=" %%i in ("%~dp0\..") do @set ConEmuDir=%%~fi
)


@%ConEmuDir%\vendor\msys2\usr\bin\bash.exe %1 "%t% %~3"

@timeout 5


:: must run this from command; in administrative mode
:: The FileType should always be created before making a File Association
:: -- ftype ShellScript=cmd /c %ConEmuDir%\bin\bash.bat -c %1 %*
:: then create the assoc
:: -- assoc .sh=ShellScript

:: HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.sh

:: HKEY_LOCAL_MACHINE\SOFTWARE\Classes\.sh

