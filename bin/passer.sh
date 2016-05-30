#!/bin/bash


PASSWORD_LENGTH=8
ACCOUNT_PATH="/home/ehiller/Google Drive/Accounts/"


# this is necessary for FIND to work with spaces in the path
# see: http://stackoverflow.com/questions/3898560/spaces-in-path-names-giving-trouble-with-find-in-bash-any-simple-work-around
IFS=$'\n'


# for ANSI formatting codes: see http://misc.flogisoft.com/bash/tip_colors_and_formatting
# for ANSI in heredoc see: http://unix.stackexchange.com/questions/266921/is-it-possible-to-use-ansi-color-escape-codes-in-bash-here-documents
textformat_yellow=$(printf '\033[33m')
textformat_red=$(printf '\033[4;91m')
textformat_normal=$(tput sgr0)

function invalidArgCount {
	echo
	echo -e "${textformat_red}WARNING: Invalid number of arguments${textformat_normal}"
	echo
	dispHelp;
}

function invalidArg {
	echo
	echo -e "${textformat_red}WARNING: Invalid argument(s):${textformat_normal}"
	if [ $1 ]; then echo -e "$1"; fi
	dispHelp;
}

function makePassword {
	hash=$(echo $RANDOM | sha512sum); echo ${hash:0:$PASSWORD_LENGTH}
}

function getAccount {
	accountname=$1
	accountfound=$(find ${ACCOUNT_PATH} -iname "*${accountname}*" -type f -ok echo {} \;)
	for i in $accountfound; do
		echo "Account Found at ${textformat_yellow}$i${textformat_normal}"
		cat $i
		echo -e "\n"
	done
}

function dispHelp {
	local me=`basename $0`
	local y=${textformat_yellow}
	local n=${textformat_normal}
# HEREDOC
cat <<EOM
*******************************************************************************
************                 PASSWORD MANAGER - help               ************
*******************************************************************************
    A quick password management script for my old text file passwords,
    So that at least I am making use of secure passwords.
    Items which appear in ${y}yellow${n} are optional 

    *** FLAG ************************** DESCRIPTION ***************************
    $me newaccount     ${y}accountname         username${n}
    $me newpass        create new password for prompted account
    $me getaccount     ${y}accountname${n}
************************ Eric D Hiller **** 28 May 2016 ***********************
EOM
exit
}

if [ $# -eq 0 ]; then invalidArgCount; fi ;
if [ $# -ge 1 ]; then
	if [ "$1" == "-h" ]; then dispHelp ;
	elif [ "$1" == "--help" ]; then dispHelp ; 
	elif [ "$1" == "-?" ]; then dispHelp ; 
	elif [ "$1" == "help" ]; then dispHelp ; 
	#elif [ "$1" == "ls" ]; then listFiles ;
#### NEW PASSWORD CREATION FOR EXISTING ACCOUNT
	elif [ "$1" == "newpass" ]; then
		echo -e "Note: Filename is the name of the site, etc..)[enter when done]:"
		read -p "Filename:   " accountname
		accountfound=$(find ${ACCOUNT_PATH} -iname "*${accountname}*" -type f)
		if [ $accountfound ] ; then 
			read -n 1 -p "Found file \"$accountfound\" correct? ( [y]es , [n]o , [r]ename )" accountname
			ENTRY="**************** `date +"%Y-%b-%d %T"` ****************\r\n"
			ENTRY="${ENTRY}PASSWORD:\t$password\r\n\r\n"
			echo -e "$ENTRY"
		else
			echo $accountname not found.
		fi
#### CREATE NEW ACCOUNT RECORD
	elif [ "$1" == "newaccount" ]; then
		echo -e "Note: Account is the name of the site, etc..)[enter when done]:"
		read -p "Account:   " accountname
		read -p "Username:   " username
		password=$(makePassword)
		ENTRY="****************"$(date +"%Y-%b-%d %T")"****************\r\n"
		ENTRY="${ENTRY}USERNAME:\t${username}\r\n"
		ENTRY="${ENTRY}PASSWORD:\t${password}\r\n"
		accountfound=$(find ${ACCOUNT_PATH} -iname "*${accountname}*" -type f)
		if [ ${accountfound} ] ; then 
			read -n 1 -p "The file \"$accountfound\" already exists, append? ( [y]es , [n]o , [r]ename ): " append
			echo -e "\n"
			#echo "0-95:|${ENTRY:0:92}|"
			#echo "90-100:|${ENTRY:90:10}|"
			#echo "95+:${ENTRY:95}|"
			if [ "$append" == "y" ]; then
				sed -b -i "1s/^/${ENTRY}\r\n/" $accountfound
			elif [ "${append}" == "r" ]; then
				read -p "(Rename)Filename:   " accountname
				accountname=${accountname}.txt
				echo -e "${ENTRY}" >> $ACCOUNT_PATH/$accountname
			else
				echo "No action taken."
			fi
		else
			accountname=${accountname}.txt
			echo -e "${ENTRY}" >> $ACCOUNT_PATH/$accountname
		fi
	elif [ "$1" == "edit" ]; then
		accountname=$2
		find ${ACCOUNT_PATH} -iname "*${accountname}*" -type f | while read line; do
			echo editing $line
			notepad.exe $line
		done
	elif [ "$1" == "getaccount" ]; then
		if [ $# -eq 1 ]; then
			read -p "Please enter account to search for: " accountname
		elif [ $# -eq 2 ]; then
			if [ "$2" ]; then
				accountname=$2
			else invalidArg "Account name of \"$2\" is invalid"
			fi
		else invalidArgCount;
		fi
		getAccount ${accountname}
	else
		if [ $1 ]; then
			accountname=$1
			getAccount ${accountname}
		fi
	fi
fi