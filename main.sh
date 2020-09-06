########################################################
# [AUTOMATED-INSERT-MARKER]
# Author Eric Johnfelt
# Date 2/15/2020

declare -a UPDCMDS
MYGITREP=ejohnfel
BASHRCGIT="https://github.com/ejohnfel/bashrc"
BASHRCVERSION="202009061309"
ISNAT=0
INTERNIP=`hostname -I`
EXTERNIP="UNKNOWN"
FIXCHECK=""
PREFIX=""
LOCATION="internal"
MYDOMAIN="digitalwicky.biz"
SAYINGS="/srv/storage/data/waiting.txt"
BSHDEBUG=0
MANPAGER='less -s -X -F'
export MANPAGER

CDPATH=.:/srv:/srv/storage:/srv/storage/projects:/srv/storage/projects/scripts:/home/ejohnfelt
export CDPATH

# DbgWrite : Internal Debug Messaging
function DbgWrite()
{
	[ ${BSHDEBUG} -gt 0 ] && MsgWrite "$(date) - ${*}"
}

# MsgWrite : Internal Messaging Function
function MsgWrite()
{
	echo -e "${*}"
}

# SetDebugMode : Get or Set BshDebugMode
function SetDebugMode()
{
	if [ "${1}" = "" ]; then
		MsgWrite "DebugMode : ${BSHDEBUG} [on or off to change]"
	elif [ "${1}" = "off" -o "${1}" = "0" ]; then
		BSHDEBUG=0
	else
		BSHDEBUG=1
	fi

	export BSHDEBUG
	#setenv BSHDEBUG
}

# Set prefix
function SetPrefix()
{
	if [ ! "${LOGNAME}" = "root" ]; then
		PREFIX="sudo"
	fi
}

# SSH Setup Stuff
function SSHSetup()
{
	NOAGENT=1

	# Early Exit COnditions
	# If root or one of the big ENV variables exists, do not run
	[ "${LOGNAME}" = "root" ] && return
	[ ! "${SSH_AGENT_PID}" = "" ] && return
	[ ! "${SSH_AUTH_SOCK}" = "" ] && return

	TMP=/tmp/tmp.${RANDOM}

	# Check for existing SSH-AGENT, no need to run more if user is already running one
	ps -u "${LOGNAME}" | grep "ssh-agent" > ${TMP}

	# Check for running SSH-AGENT
	if [ $? = 0 ]; then
		# Agent running, get PID
		PID=$(cut -d" " -f1 "${TMP}" | head -n 1)
		SSH_AGENT_PID=${PID}
		export SSH_AGENT_PID
		NOAGENT=0
	fi

	[ -e ${TMP} ] && rm ${TMP}

	if [ ${NOAGENT} = 1 ]; then
		eval `ssh-agent`

		if [ -e ~/.ssh/id_rsa ]; then
			ssh-add
		fi

		if [ -e ~/.ssh/id_rsa.home ]; then
			ssh-add ~/.ssh/id_rsa.home
		fi

		if [ -e ~/.ssh/id_rsa.work ]; then
			ssh-add ~/.ssh/id_rsa.work
		fi
	fi
}

# Clone Git Repositories From My Account
function mygit()
{
	if [ "${1}" = "-h" ]; then
		echo -e "mygit [clone|push] [repository]"
		echo -e "Enviroment variable $MYGITREP points to username for Repositories"
	else
		case "${1}" in
		"clone")	msg="Cloning from ${MYGITREP}/${2}..." ;;
		"push")		msg="Pushing to ${MYGITREP}/${2}..." ;;
		esac

		echo -e "${msg}"
		git ${1} https://github.com/${MYGITREP}/${2}
	fi
}

# Stupid Tiny Function To Show BASHRC Version
function mybashrc()
{
	if [ "${1}" = "" ]; then
		msg="MyBASHRC Version"
	else
		msg="${@}"
	fi

	echo -e "${msg} : ${BASHRCVERSION}"
}

# Manual Update
function updatemybashrc()
{
	[ ! -d /tmp ] && MsgWrite "Uh, /tmp is missing.... wow, can't continue!!!" && return

	pushd /tmp > /dev/null

	TMP="/tmp/tmp.${RANDOM}"

	git clone ${BASHRCGIT} &>  "${TMP}"

	[ ! -d /tmp/bashrc ] && MsgWrite "Could not pull down git archive, potential error msg follows\n============\n$(cat ${TMP})\n" && return

	[ -f "${TMP}" ] && rm "${TMP}"

	cd /tmp/bashrc >/dev/null

	REPVER=$(grep -E "^BASHRCVERSION\=" main.sh | cut -d"=" -f2 | tr -d "\"")

	if [ ! "${REPVER}" = "${BASHRCVERSION}" ]; then
		MsgWrite "Newer version (${REPVER}) in repository, updating now..."
		make clean > /dev/null
		make all > /dev/null
		make update > /dev/null
		sudo make automation > /dev/null

		source ~/.bash_profile > /dev/null
	else
		mybashrc "No pending updates, current version is"
	fi

	cd .. > /dev/null

	rm -Rf /tmp/bashrc

	popd > /dev/null
}

# If Syaings/Waitings File Exists, Print A Random Line From File
function RandomSaying()
{
	[ -e "${SAYINGS}" ] && shuf -n1 "${SAYINGS}"
}

# FortuneCow : Have Cow display fortunes
function FortuneCow()
{
	DbgWrite "Starting FortuneCow, checking for fortune"

	if fortune > /dev/null 2>&1 ; then
		DbgWrite "Fortune exists, checking cowsay"
		if cowsay "Test, test, test" > /dev/null 2>&1 ; then
			DbgWrite "Cowsay exists, going for it"
			fortune | cowsay
		fi
	fi
}

# Check IP against external source
function IPCheck()
{
	IPCheckResult=$(curl -s https://checkip.amazon.aws.com)
	export IPCheckResult
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
	apt-get --version > /dev/null 2>&1

	if [ $? = 0 ]; then
		FIXCHECK="apt-get --just-print upgrade | grep \"upgraded,\""
		UPDCMDS[0]="apt-get -qq update"
		UPDCMDS[1]="apt-get -qq -y upgrade"
		UPDCMDS[2]="apt-get -qq -y dist-upgrade"
		UPDCMDS[3]="apt-get -qq -y autoremove"

		return 1
	fi

	yum --version > /dev/null 2>&1

	if [ $? = 0 ]; then
		FIXCHECK="yum check-update"
		UPDCMDS=( "yum check-update" "yum -y update" "yum -y upgrade" "yum -y autoremove" )

		return 1
	fi

	pacman --version > /dev/null 2>&1

	if [ $? = 0 ]; then
		UPDCMDS[0]="pacman update"

		return 0
	fi

	opkg --version > /dev/null 2>&1

	if [ $? = 0 ]; then
		UPDCMDS[0]="opkg update"

		return 0
	fi

	dpkg --version > /dev/null 2>&1

	if [ $? = 0 ]; then
		UPDCMDS[0]="dpkg update"

		return 0
	fi

	rpm --version > /dev/null 2>&1

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
	SetPrefix

	GetPackageManager

	echo "Updating Package Manager Database..."
	eval ${PREFIX} ${UPDCMDS[0]} > /dev/null
}

# Check for Existing Updates
function CheckForUpdates()
{
	SetPrefix

	UpdateManagerDatabase

	eval ${PREFIX} ${FIXCHECK}
}

# Apply All Updates
function allupdates()
{
	echo -e "Call updateos from /usr/local/bin from now on..."
	updateos ${@}
}

# Select Screen RC
function screens()
{
	possibles=$(egrep -s -l --exclude=".bash*" "^screen -t" ~/.*)
	selected=""

	if [ "${1}" = "-l" ]; then
		printf "%-45s %s\n" "Title" "Config File"
		for item in ${possibles}; do
			title="No Title"
			egrep "^\s*#\s*title\s" "${item}" > /dev/null

			if [ $? -eq 0 ]; then
				title=$(grep "^\s*#\s*title\s" "${item}" | tr -s " " | cut -d" " -f3-)
			fi

			printf "%-45s %s\n" "${title}" "${item}"
		done
	elif [ "${1}" = "-e" ]; then
                select item in ${possibles} Quit; do
                        if [ ${item} = "Quit" ]; then
                                break
                        else
                                selected="${item}"
                                break;
                        fi
                done

                if [ ! "${selected}" = "" ]; then
                        nano "${selected}"
                fi
	elif [ "${1}" = "" ]; then
		select item in ${possibles} Quit; do
			if [ ${item} = "Quit" ]; then
				break
			else
				selected="${item}"
				break;
			fi
		done

		if [ ! "${selected}" = "" ]; then
			screen -c "${selected}"
		fi
	else
		screen -c "${1}"
	fi
}

# List Only Valid Mounts
function mounts()
{
	mount | grep -E -v "^(proc|cgroup|tmpfs|pstore|systemd|mqueue|sunrpc|tracefs|configfs|hugetlbfs|nfsd|fusectl|/var/lib/snapd|sysfs|proc|udev|devpts|securityfs|debugfs)"
}

# List Mounted Snaps
function snaps()
{
	mount | grep -E "^/var/lib/snapd"
}

# If host has a lease file, output it
function leases()
{
	local LEASEFILE=/var/lib/dhcp/dhcpd.leases

	if [ -f "${LEASEFILE}" ]; then
		if [ "${1}" = "" ]; then
			cat "${LEASEFILE}"
		else
			grep -E "${1}" "${LEASEFILE}"
		fi
	else
		printf "Host has no DHCP Leases file\n"
	fi
}

# Match MAC Addresses
function matchmac()
{
	local KNOWN="/srv/storage/data/knownhosts.csv"

	if [ -f "${KNOWN}" ]; then
		# Lower case alphas
		processed="${1,,}"

		# Best effort to convert seperators to colons
		processed="${processed/-/:}"
		processed="${processed/ /:}"

		if ! grep "${processed}" "${KNOWN}"; then
			printf "Found nothing for ${processed}\n"
			return 1
		fi

		return 0
	else
		printf "Cannot find, ${KNOWN}, database\n"
		return 1
	fi
}

# Match Supplied OUI Code with known OUI's Database
function matchoui()
{
	local OUIS="/srv/storage/data/ouis.csv"

	if [ -f "${OUIS}" ]; then
		# Lower case alphas
		processed="${1,,}"

		# Best effort to convert seperators to colons
		processed="${processed/-/:}"
		processed="${processed/ /:}"

		if [ ${#processed} -gt 8 ]; then
			old="${processed}"
			processed="${processed:0:8}"
			printf "Converting ${old} to ${processed} for search\n"
		fi

		if ! grep "${processed}" "${OUIS}"; then
			printf "Found nothing for ${processed}\n"
			return 1
		fi

		return 0
	else
		printf "Cannot find, ${OUIS}, database\n"
		return 1
	fi
}

#
# chksvcs :  Check to see if certain services are running
#
# Uses ~/.services as list to check for
#
function chksvcs()
{
	
	if [ ~/.services ]; then
		exec 9<~/.services

		while read -u 9 host svcname pattern; do
			# Skip comments
			[[ "${host}" =~ ^[\s]*# ]] && continue

			if [ "${host}" = "${HOSTNAME}" ]; then
				printf "Service : ${svcname} ("
				if ps -ef | grep -E "${pattern}" > /dev/null; then
					printf "Running)\n"
				else
					printf "NOT RUNNING ***)\n"
				fi
			fi
		done

		exec 9<&-
	else
		printf "No ~/.services file\n"
	fi
}

# List ssh hosts on ssh-config
function sshhosts()
{
	declare -a hosts_x
	declare -a dns_x

	HST=""

	hosts_x=()
	dns_x=()

	FILE="${HOME}/.ssh/config"

	max_x=20

	if [ -e ${FILE} ]; then
		while read tag value; do
			if [ "${tag}" = "host" ]; then
				HST="${value}"
				hosts_x[${#hosts_x[@]}]="${value}"

				if [ ${#value} -ge ${max_x} ]; then
					max_x=${#value}
				fi
			fi

			if [ ! "${HST}" = "" -a "${tag}" = "HostName" ]; then
				dns_x[${#dns_x[@]}]="${value}"

				HST=""
			fi
		done < ${FILE}

		for ((index=0; index < ${#hosts_x[@]}; ++index)); do
			printf "%-${max_x}s %s\n" "${hosts_x[${index}]}" "${dns_x[${index}]}"
		done
	else
		echo "No ssh config file to read"
	fi

	unset hosts_x
	unset dns_x
}

#
# List My Functions : A Meta Function
#
function myfuncs()
{
	compgen -A function | egrep -v "^_|^quote$|^quote_|^command_not|^dequote"
}

# Env Variable for DFREE
DFREECONF=~/.dfree

# Show Free Space On Storage Devices
function dfree()
{
	if [ -f ${DFREECONF} ]; then
		mapfile -t volumes < ${DFREECONF}

		printf "%-4s\t%-4s\t%-4s\t%-4s\t%4s\t%s\n" "Size" "Used" "Avail" "%Use" "Mnt" "Array"

		for ((index=0; index < ${#volumes[@]}; ++index)); do
			read volume comment <<< $(echo ${volumes[${index}]})
			mp="no"
			mountpoint -q "${volume}" && mp="yes"

			read device size used available inuse arrname <<< $(df -h ${volume} | tail -n1)

			printf "%-4s\t%-4s\t%-4s\t%-4s\t%-4s\t%-15s\t%s\n" "${size}" "${used}" "${available}" "${inuse}" "${mp}" "${volume}" "${comment}"
		done
	else
		printf "No .dfree conf found\n"
	fi
}

# MkBusySemaphore
# Parameters : [semaphore-name]
# Summary : If a name is provided, it will used, otherwise, function will
# attempt to use the PID of the executing shell. All semaphores will be
# unique, so the script must keep track of them and delete them when the
# time comes. This function is intended to be used like so.
# Example:
# mysemaphore=$(MkBusySemaphore)
# ...
# [ -f ${mysemaphore} ] && rm ${mysemaphore}
#
# In this example, the function generates the semaphore and it's full name
# and stores the full name in a variable for later reference.
# when the script is finished or no longer needs to block, use the variable
# to recover the file name and delete the semaphore from the file system
# so it does not continue to block other apps looking for the busy semaphores
function MkBusySemaphore()
{
	if [ ! "${1}" = "" ]; then
		sp="${1}.busy.${RANDOM}"
	else
		sp="${BASHPID}.busy.${RANDOM}"
	fi

	touch "${sp}"

	echo "${sp}"
}

# Determine This Machines Location
DetermineLocation

# Setup SSH Agent
SSHSetup

# Fortune Cow Say
FortuneCow

# Sayings
RandomSaying

# Only useful when 'hollywood' and/or mplayer is installed
alias mi="mplayer -vo caca /srv/storage/media/music/Soundtracks/mi.mp4"
alias os="cat /etc/os-release"
