#!/bin/bash

function UnattendedUpdates()
{
	screen -dmS updates "/usr/local/bin/updateos"
	# screen -DmS updates "/usr/local/bin/updateos"
}

UnattendedUpdates

