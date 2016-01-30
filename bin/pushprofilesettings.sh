#!/usr/bin/sh


function dispHelp {
echo "usage: `basename "$0"` username@hostname"
cat <<EOM
-------------------------------------------------------------------------------
	PROFILE SETTINGS PUSH SCRIPT - help
 	Please enter username@hostname that you would like your settings pushed to
 	Your settings (.bashrc and .vimrc) will be created from ConEmu->/config
	config/bashconf will become .bashrc and config/.vimrc will become ~/.vimrc 
--------------------Eric D Hiller----- 15 January 2016 ------------------------
EOM
exit
}

# Quick script to push your .bashrc and .vimrc to the far server // easy ssh logins
if [ $# -ne 1 ] ; then
	echo
	echo "WARNING: Invalid number of arguments"
	echo
	dispHelp
fi;

if [ "$1" == "-h" ] ; then dispHelp ;
elif [ "$1" == "--help" ] ; then dispHelp ; 
elif [ "$1" == "-?" ] ; then dispHelp ;
elif [ "$1" == "help" ] ; then dispHelp ;
fi

cat "$CMDER_ROOT/config/bashconf" | dos2unix | ssh $1 "cat > ~/.bashrc" >nul 2>&1
cat "$CMDER_ROOT/config/.vimrc" | dos2unix | ssh $1 "cat > ~/.vimrc" >nul 2>&1

# should have worked, let user know they need to refresh
echo Please log out and log back in for settings to take effect.
echo Or issue the command 'source ~/.bashrc'

