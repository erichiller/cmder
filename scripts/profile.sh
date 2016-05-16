# ERIC - EDH - setup bash

# If not running interactively, don't do anything
# this keeps SCP (file transfer from throwing errors) -- stops here
case $- in
	*i*) ;;
		*) return;;
esac

#Golang
if [ -d "/c/Go" ] ; then
	export GOROOT=/c/go
	export GOPATH=~/dev
	export PATH=$GOROOT/bin:$GOPATH/bin:$PATH
elif [ -d "$HOME/dev/lib/go" ] ; then
	export GOROOT=~/dev/lib/go
	export GOPATH=~/dev
	export PATH=$GOROOT/bin:$GOPATH/bin:$PATH	
fi

# for less / man coloring
man() {
	env \
		LESS_TERMCAP_mb=$(printf "\e[1;31m") \
		LESS_TERMCAP_md=$(printf "\e[1;31m") \
		LESS_TERMCAP_me=$(printf "\e[0m") \
		LESS_TERMCAP_se=$(printf "\e[0m") \
		LESS_TERMCAP_so=$(printf "\e[1;44;33m") \
		LESS_TERMCAP_ue=$(printf "\e[0m") \
		LESS_TERMCAP_us=$(printf "\e[1;32m") \
			man "$@"
}
# for grep coloring
export GREP_OPTIONS="--color=always"
export LESS="-R"

# for terminal line coloring
export PS1="\[$(tput sgr0)\]\[$(tput setaf 1)\]\u \[$(tput setaf 6)\]\w \[$(tput setaf 1)\]\\$ \[$(tput setaf 2)\]"
none="$(tput sgr0)"
trap 'echo -ne "${none}"' DEBUG

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*|cygwin)
	export PS1="\[\e]0;\u@\h: \w\a\]$PS1"
	;;
*)
	;;
esac

# ls dir coloring
export LS_OPTIONS='--color=auto'
eval "`dircolors -b`"
alias ls='ls $LS_OPTIONS'
alias ll='ls $LS_OPTIONS -l'
alias l='ls $LS_OPTIONS -lA'
alias pathprint='echo $PATH | tr \: \\n'

# alias vim if we are on ConEmu
if [ -f $ConEmuDir/config/.vimrc ] ; then
	alias vi='vim -u $ConEmuDir/config/.vimrc'
	alias vim='vim -u $ConEmuDir/config/.vimrc'
fi

# now read input rc
if [ -f ${ConEmuDir}/config/inputrc ] ; then bind -f ${ConEmuDir}/config/inputrc ; fi

# see startup sequence : https://www.gnu.org/software/bash/manual/html_node/Bash-Startup-Files.html
# if this is global read user files, if it is local, I am done.
# sometimes this file is used as .bashrc, sometimes it isn't, let's keep it from causing infinite loops
# (it's happened, it wasn't fun)
if [ `basename "$BASH_SOURCE"` != ".bashrc" ]; then
	if [ -f ~/.profile ]; then . ~/.profile; fi
	if [ -f ~/.bashrc ]; then . ~/.bashrc; fi
fi
