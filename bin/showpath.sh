## In cmd Echo Windows path, one directory per line

	echo %path:;=&echo.%

## For the same in powershell:

	($env:Path).Replace(';',"`n")
	 
## end for Linux / Bash / cygnwin / msysgit / sh / git

	echo $PATH | tr \: \\n