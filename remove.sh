#!/bin/bash

TARGET=~/.bashrc
TMP=/tmp/bashrc_prefix.${RANDOM}
MARKER="\\[AUTOMATED-INSERT-MARKER\\]"
UPDATE=bashrc

# make

if [ -f ${TARGET} ]; then
	echo -e "[= Detecting Marker..."

	if grep -q "${MARKER}" ${TARGET}; then
		OUTPUT=$(grep -n "${MARKER}" ${TARGET})

		if [ ! "${OUTPUT}" = "" ]; then
			echo "[= Detected Marker"
			INDEX=`echo ${OUTPUT} | cut -d ":" -f 1`

			INDEX=$(( ${INDEX} - 2 ))

			echo -e "[=== Clearing out old stuff..."
			sed -n "1,${INDEX}p" ${TARGET} > ${TMP}
			echo -e "[==== Updating ${TARGET}"
			cat ${TMP} > ${TARGET}
			echo -e "[=== Done"
			rm ${TMP}
		else
			echo "[== Detected Nothing, Can't Complete"
		fi
	else
		echo -e "[== No Marker Found, we good..."
	fi
else
	echo -e "Can't find target file: ${TARGET}"
fi
