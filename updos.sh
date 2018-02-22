########################################################
# [AUTOMATED-INSERT-MARKER]
# Author Eric Johnfelt
# Date 10/23/2017

# Update OS
function UpdateOS()
{
	PREFIX=""

	if [ ! "${LOGNAME}" = "root" ]; then
		PREFIX=sudo
	fi

	GetPackageManager

	if [ ! "$1" = "-c" ]; then
		cmds=${#UPDCMDS[*]}
		index=0

		while [ ${index} -lt ${cmds} ]; do
			eval ${PREFIX} ${UPDCMDS[${index}]}
			index=$((${index} + 1))
		done
	fi

	if [ "$1" = "-c" ]; then
		chkupd
	elif [ "$1" = "-w" ]; then
		read -p "Reboot ${HOSTNAME} (y/n)? "
		[ "${REPLY}" = "y" ] && ${PREFIX} reboot
	elif [ "$1" = "-r" -o "$1" = "-y" ]; then
		read -n 1 -t 30 -p "Rebooting ${HOSTNAME} in 30s, abort (y/n)? "
		[ ! "${REPLY}" = "y" ] && ${PREFIX} reboot
	elif [ "$1" = "-h" -o "$1" = "-s" ]; then
		read -n 1 -t 30 -p "Shutdowning down ${HOSTNAME} in 30s, abort (y/n)? "
		[ ! "${REPLY}" = "y" ] && ${PREFIX} shutdown -h now
	else
		read -t 60 -p "Reboot ${HOSTNAME} (y/N)? "

		if [ "${REPLY}" = "y" -o "${REPLY}" = "Y" ]; then
			${PREFIX} reboot
		fi
	fi
}

