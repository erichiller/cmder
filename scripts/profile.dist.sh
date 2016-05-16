# ERIC - EDH - setup bash on ConEmu /dzr

# if on CONEMU -> fix CONEMU from C:\blah\blah\blah to /c/blah/blah/blah
if [ -v ConEmuDir ] ; then
	# xterm-256color is broken, at least in ssh as of 05-May-2016 
	export TERM=cygwin
	# ensure ConEmuDir is in fact a Windows style directory and hasn't already been converted
	if [[ $ConEmuDir == *":\\"* ]] ; then
		export ConEmuDir=$(echo "/$ConEmuDir" | sed -e 's/\\/\//g' -e 's/://')
		export ConEmuBaseDir=$(echo "/$ConEmuBaseDir" | sed -e 's/\\/\//g' -e 's/://')
		# add ConEmu Directories to path for ConEmu and ConEmuC
		PATH="${ConEmuBaseDir}:${PATH}"
		PATH="${ConEmuDir}:${PATH}"
		PATH="${ConEmuDir}/bin:${PATH}"
		${ConEmuDir}/scripts/start-ssh-agent.cmd
	fi
	# auto-add vendors
	for dir in $( cat $ConEmuDir/config/vendors.json | $ConEmuDir/bin/jq.exe -r '.vendors[].binpath' ); do
		# trim newlines
		dir=$(echo $dir | tr -d '\n\r')
		dir=$ConEmuDir/vendor/$dir
		# ensure filepath exists
		if [[ -d $dir ]] ; then
			if ! $(echo "$PATH" | grep -q $dir) ; then
				export PATH=$dir:$PATH
			fi
		fi
	done
fi

# now read user settings
if [ -f ${ConEmuDir}/scripts/profile.sh ] ; then . ${ConEmuDir}/scripts/profile.sh ; fi
