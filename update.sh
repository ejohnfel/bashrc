#!/bin/bash

TARGET=~/.bash_profile
TMP=/tmp/bashrc_prefix.${RANDOM}
MARKER="\\[AUTOMATED-INSERT-MARKER\\]"
UPDATE=bashrc
OLD=~/.bashrc

# make

if [ -f ${UPDATE} ]; then
	echo -e "[= Detecting Marker..."

	if grep -q "${MARKER}" ${TARGET}; then
		OUTPUT=`grep -n "${MARKER}" ${TARGET}`

		if [ ! "${OUTPUT}" = "" ]; then
			echo "[= Detected Marker"
			INDEX=`echo ${OUTPUT} | cut -d ":" -f 1`

			INDEX=$(( ${INDEX} - 2 ))

			echo -e "[=== Clearing out old stuff..."
			sed -n "1,${INDEX}p" ${TARGET} > ${TMP}
			echo -e "[==== Updating ${TARGET}"
			cat ${TMP} ${UPDATE} > ${TARGET}
			echo -e "[=== Done"
			rm ${TMP}
		else
			echo "[== Detected Nothing, Can't Complete"
		fi
	else
		echo -e "[== No Marker Found, Adding Addendum..."
		cat ${UPDATE} >> ${TARGET}
		echo -e "[= Done"
	fi
else
	echo -e "Can't find update file: ${UPDATE}"
fi

if grep -q "${MARKER}" ${OLD}; then
	printf "Detected marker in ${OLD}, removing from there..."
	./remove.sh
fi
