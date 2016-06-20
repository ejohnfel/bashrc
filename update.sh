#!/bin/bash

MARKER="[AUTOMATED_INSERT-MARKER]"

grep "${MARKER}" ~/.bashrc > /dev/null

if [ $? = 0 ]; then
	index=`grep -l "${MARKER}" ~/.bashrc`
else
	cat bashrc >> ~/.bashrc
fi
