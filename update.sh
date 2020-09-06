#!/bin/bash

BACKUP=1
DEBUGMODE=0
TARGET=~/.bash_profile
TMP=/tmp/bashrc_prefix.${RANDOM}
MARKER="\\[AUTOMATED-INSERT-MARKER\\]"
UPDATE=bashrc
ALIASES=aliases.sh
BASHRC=~/.bashrc

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

# Remove Marker and anything past it
# Parameters: [file to update] [file to add]
function Update()
{
	OUTPUT=$(grep -n "${MARKER}" ${1})

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

if grep -q "${MARKER}" ${BASHRC} && ! grep -q "${MARKER}" "${TARGET}"; then
	Msg "Detected marker in ${BASHRC}, removing from there..."
	./remove.sh
fi

if [ -f ${UPDATE} ]; then
	Msg "[= Detecting Marker..."

	if grep -q "${MARKER}" ${TARGET}; then
		Update "${TARGET}" "${UPDATE}"
	else
		Msg "[== No Marker Found, Adding Addendum..."
		Append "${UPDATE}" "${TARGET}"
		Msg "[= Done"
	fi

	if grep -q "${MARKER}" "${BASHRC}"; then
		Update "${BASHRC}" "${ALIASES}"
	else
		Msg "[== No Marker, appending ${ALIASES} to ${BASHRC}"
		Append "${ALIASES}" "${BASHRC}"
		Msg "[= Done"
	fi
else
	Msg "Can't find update file: ${UPDATE}"
fi
