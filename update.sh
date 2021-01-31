#!/bin/bash

BACKUP=1
DEBUGMODE=0
TMP=/tmp/bashrc_prefix.${RANDOM}
MARKER="\\[AUTOMATED-INSERT-MARKER\\]"

BASHRC=~/.bashrc
BASHRCCODE=bashrc

BASH_PROFILE=~/.bash_profile
PROFILECODE="profile.txt"

#
# Functions
#

# Msg Function
# Parameter: [message]
function Msg()
{
	if [ ${DEBUGMODE} -eq 0 ]; then
		printf "%s\n" "${*}"
	else
		printf "$(date) : %s\n" "${*}"
	fi
}

# Remove Marker and code that follows it
function Remove()
{
	if [ -f "${1}" ]; then
		echo -e "[= Detecting Marker..."

		if grep -q "${MARKER}" "${1}"; then
			OUTPUT=$(grep -n "${MARKER}" "${1}")

			if [ ! "${OUTPUT}" = "" ]; then
				echo "[= Detected Marker"
				INDEX=`echo ${OUTPUT} | cut -d ":" -f 1`

				INDEX=$(( ${INDEX} - 2 ))

				echo -e "[=== Clearing out old stuff..."
				sed -n "1,${INDEX}p" "${1}" > ${TMP}
				echo -e "[==== Updating ${1}"
				cat ${TMP} > "${1}"
				echo -e "[=== Done"
				rm ${TMP}
			else
				echo "[== Detected Nothing, Can't Complete"
			fi
		else
			echo -e "[== No Marker Found, we good..."
		fi
	else
		echo -e "Can't find target file: ${1}"
	fi
}


# Remove Marker and anything past it
# Parameters: [file to update] [file to add] [marker]
function Update()
{
	OUTPUT=$(grep -n "${3}" ${1})

	if [ ! "${OUTPUT}" = "" ]; then

		if [ ${BACKUP} -gt 0 ]; then
			bname=$(basename "${1}")
			cp "${1}" "/tmp/${bname}.bak"
		fi

		Msg "[= Detected Marker"
		INDEX=$(printf "${OUTPUT}" | cut -d ":" -f 1)

		INDEX=$(( ${INDEX} - 2 ))

		Msg "[=== Clearing out old stuff..."
		sed -n "1,${INDEX}p" ${1} > ${TMP}
		Msg "[==== Updating ${1}"
		cat ${TMP} ${2} > ${1}
		Msg "[=== Done"
		rm ${TMP}
	else
		Msg "[== Detected Nothing, Can't Complete"
	fi
}

# Append To End of File
# Parameters : [file to add] [file to be added too]
function Append()
{
	if [ ${BACKUP} -gt 0 ]; then
		bname=$(basename "${2}")
		cp "${2}" "/tmp/${bname}.bak"
	fi

	cat "${1}" >> "${2}"
}

#
# Main Loop
#

Remove "${BASHRC}"
Remove "${BASH_PROFILE}"

if grep -q "${MARKER}" "${BASH_PROFILE}"; then
	Update "${TARGET}" "${PROFILECODE}" "${MARKER}"
else
	Msg "[== No Marker Found, appending to ${BASH_PROFILE}..."
	Append "${PROFILECODE}" "${BASH_PROFILE}"
	Msg "[= Done"
fi

if grep -q "${MARKER}" "${BASHRC}"; then
	Update "${BASHRC}" "${BASHRCCODE}" "${MARKER}"
else
	Msg "[== No Marker, appending to ${BASHRC}"
	Append "${BASHRCCODE}" "${BASHRC}"
	Msg "[= Done"
fi
