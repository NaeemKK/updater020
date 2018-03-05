#!/bin/bash

ERROR_OCCURED=1
CHECK_STAT_AT_REBOOT=2

type=`jq '.type' package.json`
version=`jq '.version' package.json`
if [ "$type" = "kernel" ];
then
	if [ -e "uImage" ];
	then
		if [  -e "/root/failed" ];
		then
			mv ./uImage /boot/
			rm /root/failed
		else
			cp /boot/uImage /boot/uImage1
			mv ./uImage /boot/
			sync
		fi
		## at bootup check version of kernel for upgrade status
		gawk -i inplace -F" " -vOFS=" "  '$1=="check_version"{$2=$version}1;' ~/.bashrc		
		ret=$CHECK_STAT_AT_REBOOT	
	else
		echo "missing uImage"
		ret=$ERROR_OCCURED
	fi
else if [ "$type" = "package" ];
then
	echo "package"
	cmd=`jq '.command' package.json`
	$cmd
	ret=$?
else if [ "$type" = "application" ];
then
	echo "application"
	## discuss location of applications
fi

exit $ret


