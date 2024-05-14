########################################################
# [AUTOMATED-INSERT-MARKER]
# Author Eric Johnfelt
# Date 1/30/2021

shopt -s extglob

[ -f ~/.bash_functions ] && source ~/.bash_functions

if [[ $- =~ .*i.* ]]; then
	if which screen > /dev/null; then
		# if which returns a zero value, then screen is installed
		# and we may now proceed, otherwise, we don't bother using it.

		if ! screen -ls "Login SCREEN" > /dev/null; then
			# No Login SCREEN
			NewNamedScreen "Login SCREEN" "Login Screen"
		else
			printf "Login Screen Exists\n"
			echo -e "\a"
			read -n1 -t10 -p "Connect (y/n)? "
			printf "\n"

			if [ "${REPLY}" = "y" ]; then
				SelectScreen
			fi

			read -n1 -t10 -p "Create a new one (y/n)? "
			printf "\n"

			if [ "${REPLY}" = "y" ]; then
				read -p "Session Name : " SESSIONNAME
				read -p "Window Title : " TITLE
				printf "\n"
				printf "Remember... CTRL-a a to send commands to a nested SCREEN instance"
				sleep 5s
				NewNamedScreen "${SESSIONNAME}" "${TITLE}"
			fi
		fi
	fi
fi

[ -f ~/.bashrc ] && source ~/.bashrc
