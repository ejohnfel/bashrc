#!/bin/bash

BACKUP=1
DEBUGMODE=0
TMP=/tmp/bashrc_prefix.${RANDOM}
MARKER="\\[AUTOMATED-INSERT-MARKER\\]"

SRC="${1}"
DST="${2}"

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
		echo -e "[= Can't find target file: ${1}, creating empty file"
		touch "${1}"
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

Remove "${DST}"

if grep -q "${MARKER}" "${DST}"; then
	Update "${DST}" "${SRC}" "${MARKER}"
else
	Msg "[== No Marker, appending to ${DST}"
	Append "${SRC}" "${DST}"
	Msg "[= Done"
fi
