#!/bin/bash

function log() { echo "[`date`] $1"; }
 
_mypid=$$
_appName=displayService

xrandr > /tmp/$_appName.xrandr.current
if [ ! -e /tmp/$_appName.xrandr.baseline ]; then
	cat /tmp/$_appName.xrandr.current
else
	diff /tmp/$_appName.xrandr.current /tmp/$_appName.xrandr.baseline 
	if [ $? == 0 ]; then
		echo "#NODIFF `date +'%Y/%m/%d %H:%M:%S'`"
	else
		cat /tmp/$_appName.xrandr.current	
	fi
fi
cp /tmp/$_appName.xrandr.current /tmp/$_appName.xrandr.baseline

