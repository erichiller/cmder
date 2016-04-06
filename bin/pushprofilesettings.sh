#!/usr/bin/sh


function dispHelp {
echo "usage: `basename "$0"` username@hostname"
cat <<EOM
-------------------------------------------------------------------------------
    PROFILE SETTINGS PUSH SCRIPT - help
    
    Please enter username@hostname that you would like your settings pushed to
	
    Your settings (.bashrc and .vimrc) will be created from ConEmu->/config
    config/profile.sh will become .bashrc and config/.vimrc will become ~/.vimrc 
    
    Your public key will be taken from ~/.ssh/id_rsa.pub [windows home]
	
    *** FLAG ************************** DESCRIPTION ***************************
    -i  <alternate id_rsa.pub file>     use this file to send to server instead
--------------------Eric D Hiller----- 15 January 2016 ------------------------
EOM
exit
}

function pushprofile {
	echo Sending .bashrc to $1
	cat "$CMDER_ROOT/config/profile.sh" | dos2unix | ssh $1 "cat > ~/.bashrc" >nul 2>&1
	
	echo Sending .vimrc to $1
	cat "$CMDER_ROOT/config/.vimrc" | dos2unix | ssh $1 "cat > ~/.vimrc" >nul 2>&1
}

function pushKey {
	echo Sending $1 to $2 as an authorized key.
	cat $1 | ssh $2 "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"
}

function invalidArgCount {
	echo
	echo "WARNING: Invalid number of arguments"
	echo
	dispHelp;
}

# Quick script to push your .bashrc and .vimrc to the far server // easy ssh logins
if [ $# -gt 3 ] ; then invalidArgCount ;
elif [ $# -eq 3 ] ; then
	# -i keyfile user@host
	if [ "$1" == "-i" ] ; then pushKey $2 $3;
	fi;
elif [ $# -eq 2 ] ; then invalidArgCount ;
elif [ $# -eq 1 ] ; then 
	if [ "$1" == "-h" ] ; then dispHelp ;
	elif [ "$1" == "--help" ] ; then dispHelp ; 
	elif [ "$1" == "-?" ] ; then dispHelp ;
	elif [ "$1" == "help" ] ; then dispHelp ;
	else
		# default actions
		pushKey ~/.ssh/id_rsa.pub $1
		pushprofile $1
	fi;
else dispHelp;
fi;

# should have worked, let user know they need to refresh
echo Please log out and log back in for settings to take effect.
echo Or issue the command 'source ~/.bashrc'

