#!/bin/bash
set -x
ERROR_OCCURED=1
CHECK_STAT_AT_REBOOT=2
	
type=`jq '.type' package.json | sed -e 's/^"//' -e 's/"$//'`

if [ "$type" = "kernel" ]
then
	version=`jq '.version' package.json`
	if [ -e "uImage" ]
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
elif [ "$type" = "package" ]
then
	echo "package"
	cmd=`jq '.command' package.json`
	$cmd
	ret=$?
elif [ "$type" = "application" ]
then
	echo "application"
	action=`jq '.action' package.json | sed -e 's/^"//' -e 's/"$//'`
	path=`jq '.path' package.json | sed -e 's/^"//' -e 's/"$//'`
	application_name=`jq '.package_name' package.json | sed -e 's/^"//' -e 's/"$//'`
	script_name=`jq '.script_name' package.json | sed -e 's/^"//' -e 's/"$//'`
	
	bash -C application_script $action $path $application_name $script_name &
	ret=$?
else
	echo "Wrong Type"
	ret=-1
fi

exit $ret

