# DESCRIPTION 

Readme for **EDH dist ConEmu setup** -- EDH NOTES

This project started from cmder, which itself was a compendium of software around the wonderful ConEmu.

**THIS FILE NEEDS TO BE REWORKED**

## Upgrade

vscode



Use the `upgrade.bat` script in `scripts/`

	%ConEmuDir%\scripts\upgrade.bat

As this will kill the console that it runs in - **Ensure to run this in an _out of ConEmu_ `cmd.exe` prompt**, this can be done by pressing `WIN` + `R` keys and typing `cmd.exe` 


add paths for new programs into:

	vendor/profile.ps1 for powershell
	vendor/init.bat for cmd
	vendor/msys2

This line in ConEmu.xml config breaks Far.exe left click:
see: <https://github.com/Maximus5/ConEmu/issues/334#event-419601706>

	<!-- EVIL LINE; BREAKS FAR.EXE				<value name="WndDragKey" type="dword" data="80808001"/>		-->

# Main goals / Purpose
Try to maintain portability.
	!! trying to keep user _settings_ in /config
	!! trying to keep user  _secure data_
							_history_
							_temporary files_ in %USERPROFILE% (aka the home directory)

 I BELIEVE all customizations to be in: (but don't count on it):
	vendor/profile.ps1
	vendor/init.bat
	config/
	bin/
	msys2/usr/bin/vim
	msys2/etc/profile
	scripts/helpfile
	vendor/irssi
!!!!	vendor/github-for-windows/cmd/start-ssh-agent.bat
------------> I rewrote this and it is important!!!!!

# Far Manager
1. put the conemu plugins into farmanager
2. Erase the autowrap plugin
3. Put the maximus wrap plugin into farmanager

# Transfer Directory Structure

Git does NOT upload blank directories, but (msys2 especially) the destination machine can require these upon restoration.

To back up the directories run(in msys2/bash):

	find /c/blue -type d > directory.listing
	
And then restore with

	cat directory.list.txt | xargs mkdir
