########################################################
# [AUTOMATED-INSERT-MARKER]
# Author Eric Johnfelt
# Date 7/30/2019

# Update OS
function UpdateOS()
{
	CMD=""
	NOTIFY="no"
	REPLYDELAY="60"
	EXECDELAY=""
	PREFIX=""

	if [ ! "${LOGNAME}" = "root" ]; then
		PREFIX=sudo
	fi

	GetPackageManager

	while [ ! "${1}" = "" ]; do
		case "${1}" in
		"-c") CMD=check ;;
		"-w") CMD=wait ;;
		"-r") CMD=reboot ;;
		"-h") CMD=halt ;;
		"-n") NOTIFY="yes" ;;
		"-t") REPLYDELAY="${2}"; shift 1 ;;
		"-e") EXECDELAY="${2}"; shift 1 ;;
		esac

		shift 1
	done

	if [ ! "${EXECDELAY}" = "" ]; then
		sleep ${EXECDELAY}
	fi

	if [ "${NOTIFY}" = "yes" ]; then
		${PREFIX} wall "The system is about to patch, it will likely reboot, you have 5 minutes to finish what you are doing"

		sleep 5m
	fi

	if [ ! "${CMD}" = "check" ]; then
		echo -e "Beginning Update of ${HOSTNAME}..."
		cmds=${#UPDCMDS[*]}
		index=0

		while [ ${index} -lt ${cmds} ]; do
			eval ${PREFIX} ${UPDCMDS[${index}]}
			index=$((${index} + 1))
		done

		case "${CMD}" in
		"wait")
			read -p "Reboot ${HOSTNAME} (y/n)? "
			[ "${REPLY}" = "y" -o "${REPLY}" = "Y" ] && ${PREFIX} reboot ;;
		"reboot")
			read -n 1 -t ${REPLYDELAY} -p "Rebooting ${HOSTNAME} in ${REPLYDELAY}s, abort (y/n)? "
			[ ! "${REPLY}" = "y" ] && ${PREFIX} reboot ;;
		"halt")
			read -n 1 -t ${REPLYDELAY} -p "Shutting down ${HOSTNAME} in ${REPLYDELAY}s, abort (y/n)? "
			[ ! "${REPLY}" = "y" ] && ${PREFIX} shutdown -h now ;;
		*)
			read -t 60 -p "Reboot ${HOSTNAME} (y/N)? "
			[ "${REPLY}" = "y" -o "${REPLY}" = "Y" ] && ${PREFIX} reboot
		esac
	else
		chkupd
	fi
}

