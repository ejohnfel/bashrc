########################################################
# [AUTOMATED-INSERT-MARKER]
# Author Eric Johnfelt
# Date 7/30/2019

declare -a UPDCMDS
MYGITREP=ejohnfel
BASHRCGIT="https://github.com/ejohnfel/bashrc"
BASHRCVERSION="2019112520192324"
ISNAT=0
INTERNIP=`hostname -I`
EXTERNIP="UNKNOWN"
FIXCHECK=""
PREFIX=""
LOCATION="internal"
MYDOMAIN="digitalwicky.biz"
SAYINGS="/srv/storage/data/waiting.txt"

CDPATH=/srv:/srv/storage:/srv/storage/projects:/srv/storage/projects/scripts:/home/ejohnfelt
export CDPATH

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
	pushd /tmp > /dev/null

	mybashrc "Current Version"

	git clone ${BASHRCGIT}

	cd bashrc

	make clean
	make all
	make update
	sudo make automation

	cd ..

	rm -Rf bashrc

	source ~/.bashrc

	mybashrc "New Version"

	popd > /dev/null
}

# If Syaings/Waitings File Exists, Print A Random Line From File
function RandomSaying()
{
	[ -e "${SAYINGS}" ] && shuf -n1 "${SAYINGS}"
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

# List My Functions
function myfuncs()
{
	compgen -A function | egrep -v "^_|^quote$|^quote_|^command_not|^dequote"
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

# Determine This Machines Location
DetermineLocation

# Setup SSH Agent
SSHSetup

# Sayings
RandomSaying

# Only useful when 'hollywood' and/or mplayer is installed
alias mi="mplayer -vo caca /srv/storage/media/music/Soundtracks/mi.mp4"
