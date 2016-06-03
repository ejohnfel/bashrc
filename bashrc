
########################################################
# [AUTOMATED-INSERT-MARKER]
# Author Eric Johnfelt
# Date 5/5/2016

# Determine Package Manager
function GetPackageManager()
{
	apt-get --version > /dev/null

	if [ $? = 0 ]; then
		UPDCMDS[0]="apt-get update"
		UPDCMDS[1]="apt-get -y upgrade"
		UPDCMDS[2]="apt-get -y dist-upgrade"
		UPDCMDS[3]="apt-get -y autoremove"

		return 1
	fi

	pacman --version

	if [ $? = 0 ]; then
		UPDCMDS[0]="pacman update"

		return 1
	fi

	opkg --version

	if [ $? = 0 ]; then
		UPDCMDS[0]="opkg update"

		return 1
	fi

	dpkg --version

	if [ $? = 0 ]; then
		UPDCMDS[0]="dpkg update"

		return 0
	fi

	rpm --version

	if [ $? = 0 ]; then
		UPDCMDS[0]="rpm update"

		return 0
	fi

	echo -e "Cannot determine package manager.. quitting..."

	return 0
}

# Apply All Updates
function allupdates()
{
	PREFIX=""

	if [ ! "${LOGNAME}" = "root" ]; then
		PREFIX=sudo
	fi

	GetPackageManager

	cmds=${#UPDCMDS[*]}
	index=0

	while [ ${index} -lt ${cmds} ]; do
		eval ${PREFIX} ${UPDCMDS[${index}]}
		index=$((${index} + 1))
	done

	if [ "$1" = "-r" -o "$1" = "-y" ]; then
		${PREFIX} reboot
	else
		read -t 60 -p "Reboot (y/N)? "

		if [ "${REPLY}" = "y" -o "${REPLY}" = "Y" ]; then
			${PREFIX} reboot
		fi
	fi	
}

alias mkroot="sudo bash"
