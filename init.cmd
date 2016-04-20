:: Init Script for cmd.exe
:: Sets some nice defaults
:: Eric D Hiller
:: 17 April 2016

SET ConEmuDir=%~dp0

SET PROGRAMNAME=ConEmu64.exe
tasklist.exe /FI "IMAGENAME eq %PROGRAMNAME%" 2>NUL | find.exe /I /N "%PROGRAMNAME%">NUL
if "%ERRORLEVEL%"=="0" (
	start %ConEmuDir%ConEmu64.exe -NoSingle -NoUpdate -LoadCfgFile "%ConEmuDir%config\ConEmu.xml" -SaveCfgFile "%ConEmuDir%config\ConEmu_detached.xml" -GuiMacro "WindowPosSize(0,0,\"100%%\",\"25%%\"); SetOption(\"Check\",2333,0); WindowMode(9)" -cmd {Msys2}
) ELSE (
	start %ConEmuDir%\ConEmu64.exe /LoadCfgFile "%ConEmuDir%config\ConEmu.xml" /Icon "%ConEmuDir%icons\cmder.ico"
)

