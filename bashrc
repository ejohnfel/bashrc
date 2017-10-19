########################################################
# [AUTOMATED-INSERT-MARKER]
# Author Eric Johnfelt
# Date 5/5/2016

declare -a UPDCMDS
MYGITREP=ejohnfel
BASHRCVERSION="0.1"
ISNAT=0
INTERNIP=`hostname -I`
EXTERNIP="UNKNOWN"
FIXCHECK=""
PREFIX=""
LOCATION="internal"
MYDOMAIN="digitalwicky.biz"

# Clone Git Repositories From My Account
function mygit()
{
	git ${1} https://github.com/${MYGITREP}/${2}
}

# Determine Location of This Machine (and update MYDOMAIN,LOCATION variables)
function DetermineLocation()
{
	# If internal, digitalwicky.biz
	# If external, digitalwicky.net
	# Note, firewall settings may prevent use of resources
	TMP=/tmp/dl.${RANDOM}
	hostname -I > ${TMP}

	while read ipaddr; do
		prefix=`echo ${ipaddr} | cut -d"." -f 1,2`

		case "${prefix}" in
		"192.168")
			LOCATION="internal"
			MYDOMAIN="digitalwicky.biz"
			;;
		*)
			LOCATION="external"
			MYDOMAIN="digitalwicky.net"
			;;
		esac
	done < ${TMP}

	rm ${TMP}
}

# Determine NAT and External IP (NPING/NMAP must be installed, must be able to sudo)
# Sets ${ISNAT}, ${INTERNIP} and ${EXTERNIP} Environment Variables
function DetectNAT()
{
	nping > /dev/null

	if [ ! $? = 1 ]; then
		echo -e "Nping not installed, cannot determine NAT"
		INTERNIP=`hostname -I`
		EXTERNIP="UNKNOWN"
		ISNAT=0

		return 127
	else
		TMP=/tmp/detectnat.${RANDOM}

		sudo nping --ec "public" -c 1 echo.nmap.org > ${TMP}

		INTERNIP=`grep SENT ${TMP} | cut -d" " -f4 | cut -d"[" -f2`
		EXTERNIP=`grep CAPT ${TMP} | cut -d" " -f4 | cut -d"[" -f2`

		if [ "${INTERNIP}" = "${EXTERNIP}" ]; then
			ISNAT=0
		else
			ISNAT=1
		fi

		rm ${TMP}
	fi

	return 0
}

# Show NAT Status
function isnat()
{
	DetectNAT

	if [ ${ISNAT} = 1 ]; then
		echo -e "[=== This host is NAT/PAT'ed"
		echo -e "[=== Internal IP : ${INTERNIP}"
		echo -e "[=== External IP : ${EXTERNIP}"
	else
		echo -e "[=== This host is NOT NAT/PAT'ed"
		echo -e "[=== IP : ${INTERNIP}"
	fi
}

# Determine Package Manager
function GetPackageManager()
{
	apt-get --version > /dev/null

	if [ $? = 0 ]; then
		FIXCHECK="apt-get --assume-no upgrade"
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

# Update Package Manager's Database
function UpdateManagerDatabase()
{
	PREFIX=""

	if [ ! "${LOGNAME}" = "root" ]; then
		PREFIX=sudo
	fi

	GetPackageManager

	eval ${PREFIX} ${UPDCMDS[0]}
}

# Check for Existing Updates
function CheckForUpdates()
{
	UpdateManagerDatabase

	eval ${PREFIX} ${FIXCHECK}
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
		read -t 30 -p "Rebooting in 30s, abort (y/n)? "
		[ ! "${REPLY}" = "y" ] && ${PREFIX} reboot
	elif [ "$1" = "-h" -o "$1" = "-s" ]; then
		read -t 30 -p "Shutdowning down in 30s, abort (y/n)? "
		[ ! "${REPLY}" = "y" ] && ${PREFIX} shutdown -h now
	else
		read -t 60 -p "Reboot (y/N)? "

		if [ "${REPLY}" = "y" -o "${REPLY}" = "Y" ]; then
			${PREFIX} reboot
		fi
	fi
}

# Determine This Machines Location
DetermineLocation

# Aliases

alias rootme="sudo bash"
alias cls="clear"

