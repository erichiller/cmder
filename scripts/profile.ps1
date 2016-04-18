# Init Script for powershell
# Sets some nice defaults
# Eric D Hiller
# 17 April 2016

# these variables are only used internally within this script to set external items
# then discarded to avoid confusion
$local:GOROOT = (Join-Path $env:USERPROFILE "\dev\lib\go")
$local:GOPATH = (Join-Path $env:USERPROFILE "\dev")
$local:LocalBinDir = (Join-Path $env:ConEmuDir "\bin")

$VENDORS = & "$env:ConEmuDir\vendor\msys2\usr\bin\cat" "$env:ConEmuDir\config\vendors.json" | & "$env:ConEmuDir\bin\jq.exe" -r ".vendors[].binpath"
foreach ($vendor in $VENDORS){
	$vendor = $vendor -replace "`t|`n|`r",""
	$vendor = $vendor -replace " ;|; ",";"
	$path = "$env:ConEmuDir\vendor\$vendor"
	if (Test-Path -Path $path ) {
		if( -not $env:Path.Contains($path) ){
			$env:Path += ";$path"
		}
	}
}

# Compatibility with PS major versions <= 2
if(!$PSScriptRoot) {
	$PSScriptRoot = Split-Path $Script:MyInvocation.MyCommand.Path
}

# Add GOPATH
# ensure the path exists
if (Test-Path -Path $GOROOT ) {
	# set these up no matter, it doesn't hurt anything, it just overwrites
	# although I could see a case where you would want to have these maintained from the prior session
	# ie. cross compile
	# could change later if I encounter this?
	$env:GOROOT = $GOROOT
	$env:GOPATH = $GOPATH
	# ensure it isn't already added, as in the case of root tab copy
	if( -not $env:Path.Contains($GOPATH) ){
		$env:Path += ";$env:GOROOT\bin\;$env:GOPATH\bin\"
	}
}

$ConEmuModulePath = Join-path $env:ConEmuDir "\vendor\psmodules\"
# Add local modules directory to the autoload path.
if( -not $env:PSModulePath.Contains($ConEmuModulePath) ){
	$env:PSModulePath = $env:PSModulePath.Insert(0, $ConEmuModulePath + ";")
}

try {
	# Check if git is on PATH, i.e. Git already installed on system
	Get-command -Name "git" -ErrorAction Stop >$null
} catch {
	# add binaries
	$env:Path += ";$env:ConEmuDir\vendor\msys2\usr\bin"
}

try {
	# test for git
	Import-Module -Name "posh-git" -ErrorAction Stop >$null
	# set status as true
	$gitStatus = $true
	# setup git-bash/msysgit aliases
	set-alias gunzip bashcall
	set-alias irssi bashcall
	Remove-Item alias:curl
	set-alias curl bashcall
	# mingw
	if ( (Test-Path -Path (Join-Path $env:ConEmuDir "\vendor\msys2\mingw32\bin")) -and ( $env:PROCESSOR_ARCHITECTURE -eq "x86" ) ) {
		if( -not $env:Path.Contains("$env:ConEmuDir\vendor\msys2\mingw32\bin") ){
			$env:Path += ";$env:ConEmuDir\vendor\msys2\mingw32\bin"
		}
	} elseif ( (Test-Path -Path (Join-Path $env:ConEmuDir "\vendor\msys2\mingw64\bin")) -and ( $env:PROCESSOR_ARCHITECTURE -eq "AMD64" ) ) {
		if( -not $env:Path.Contains("$env:ConEmuDir\vendor\msys2\mingw64\bin") ){
			$env:Path += ";$env:ConEmuDir\vendor\msys2\mingw64\bin"
		}
	}
} catch {
	Write-Warning "Missing git support, install posh-git with 'Install-Module posh-git' and restart conemu."
	$gitStatus = $false
}
# set alias (for no arguments ) // functions (for arguments)
Remove-Item alias:wget
function wget { wget.exe --no-check-certificate $args }

# set alias (for no arguments ) // functions (for arguments)
Remove-Item alias:ls
function ls { ls.exe -l --color $args }

Set-Alias vi vim
function vim { & ( (Join-Path $env:ConEmuDir '\vendor\vim\vim74\vim.exe') ) -u (Join-Path $env:ConEmuDir '/config/.vimrc' ) $args  }

# set-alias -passthru bashcall # debug
function bashcall {
	#echo "entered bashcall"
	#echo "args="
	#echo $args
	#echo "last command="
	#echo $$
	#echo "myinvocation="
	#echo $myinvocation
	#echo "myinvocation.invocationname="
	#echo $myinvocation.invocationname
	& ( $env:ConEmuDir + "\vendor\msys2\usr\bin\bash.exe" ) -c '"' $myinvocation.invocationname $args '"'
}

function checkGit($Path) {
	if (Test-Path -Path (Join-Path $Path '.git/') ) {
		Write-VcsStatus
		return
	}
	$SplitPath = split-path $path
	if ($SplitPath) {
		checkGit($SplitPath)
	}
}

# EDH -
# Set up a custom-bash-like prompt, adding the git prompt parts inside git repos
function global:prompt {
	$realLASTEXITCODE = $LASTEXITCODE
	$Host.UI.RawUI.ForegroundColor = "White"
	# see https://technet.microsoft.com/library/hh849877.aspx for Write-Host information
	Write-Host ($Env:USERNAME,"") -NoNewLine -ForegroundColor Red
	Write-Host $pwd.ProviderPath -NoNewLine -ForegroundColor Cyan
	if($gitStatus){
		checkGit($pwd.ProviderPath)
	}
	$global:LASTEXITCODE = $realLASTEXITCODE
	Write-Host " $" -NoNewLine -ForegroundColor Red
	# write the title as the current Path
	$host.ui.RawUI.WindowTitle = $(Get-Location)
	return " "
}
# load local psmodules
#$global:UserModuleBasePath = Join-Path -Path $ENV:ConEmuDir -ChildPath 'vendor\psmodules'
$global:UserModuleBasePath = $PSScriptRoot
# load GitStatusCachePoshClient
# see: https://github.com/cmarcusreid/git-status-cache-posh-client
Import-Module -Name "GitStatusCachePoshClient" -ErrorAction Stop >$null
# For information on Git display variables, see:
# C:\cmder\vendor\psmodules\posh-git\GitPrompt.ps1
# posh-git change name of tab // remove annoying
$GitPromptSettings.EnableWindowTitle = "git:"

# Run the GIT- Start Agent Script rather than Post-Git
if ($gitStatus) {
#	Start-SshAgent
	& ( $env:ConEmuDir + "\scripts\start-ssh-agent.cmd" )
	echo "ended"
#	$Env:SSH_AUTH_SOCK=$env:TMP + "\ssh-agent.sock"
}

# Add local bin dir (for single file executable or user-runnable scripts)
# ensure the path exists
if (Test-Path -Path $LocalBinDir ) {
	# ensure it isn't already added, as in the case of root tab copy
	if( -not $env:Path.Contains($LocalBinDir) ){
		$env:Path += ";" + $LocalBinDir
	}
}
