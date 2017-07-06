#!/bin/bash

TARGET=~/.bashrc
TMP=/tmp/bashrc_prefix.${RANDOM}
MARKER="\\[AUTOMATED-INSERT-MARKER\\]"
UPDATE=bashrc

make

if [ -f ${UPDATE} ]; then
	echo -e "[= Detecting Marker..."
	grep "${MARKER}" ~/.bashrc > /dev/null

	if [ $? = 0 ]; then
		OUTPUT=`grep -n "${MARKER}" ~/.bashrc`

		if [ ! "${OUTPUT}" = "" ]; then
			echo "[= Detected Marker"
			INDEX=`echo ${OUTPUT} | cut -d ":" -f 1`

			INDEX=$(( ${INDEX} - 2 ))

			echo -e "[=== Clearing out old stuff..."
			sed -n "1,${INDEX}p" ${TARGET} > ${TMP}
			echo -e "[==== Updating ${TARGET}"
			cat ${TMP} bashrc > ${TARGET}
			echo -e "[=== Done"
			rm ${TMP}
		else
			echo "[== Detected Nothing, Can't Complete"
		fi
	else
		echo -e "[== No Marker Found, Adding Addendum..."
		cat bashrc >> ~/.bashrc
		echo -e "[= Done"
	fi
else
	echo -e "Can't find update file: ${UPDATE}"
fi
