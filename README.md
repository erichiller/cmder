# README -- EDH NOTES

Quite custom build - sourced from 1.2, but massively changed.


add paths for new programs into:

	vendor/profile.ps1 for powershell
	vendor/init.bat for cmd
	vendor/msys2

This line in ConEmu.xml config breaks Far.exe left click:
see: https://github.com/Maximus5/ConEmu/issues/334#event-419601706

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

	find /c/cmder -type d > directory.listing
	
And then restore with

	cat directory.list.txt | xargs mkdir
