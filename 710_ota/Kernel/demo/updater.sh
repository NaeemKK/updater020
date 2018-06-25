#!/bin/bash
set -x
ERROR_OCCURED=-1
SUCCESS=0	
type=`jq '.type' package.json | sed -e 's/^"//' -e 's/"$//'`

if [ "$type" = "kernel" ]
then
	version=`jq '.version' package.json | sed -e 's/^"//' -e 's/"$//'`
	if [ -e "zImage" ]
	then
		echo "Remounting /boot Read/Write"			
		mount -o remount,rw /boot && mount -o remount,rw /lib/modules
		if [ $? -eq 0 ]
		then
			umount /mnt 2> /dev/null
			mount -o loop modules.img /mnt
			if [ $? -eq 0 ]
			then				
				cp -rf /mnt/$version /lib/modules/
				if [ $? -eq 0 ]
				then
					if [  -e "/root/failed" ];
					then
						cp -f ./zImage /boot/
						cp -f s5p4418-artik530-raptor-rev03.dtb /boot/
						rm /root/failed
						sync
					else
						cp -f /boot/zImage /boot/zImage_1
						cp -f ./zImage /boot/
						cp -f /boot/s5p4418-artik530-raptor-rev03.dtb /boot/s5p4418-artik530-raptor-rev03_1.dtb
						cp s5p4418-artik530-raptor-rev03.dtb /boot/
						touch /root/new
						sync
					fi
					echo "Remounting /boot Read only"
					mount -o remount,rw /boot
					mount -o remount,rw /lib/modules
					umount /mnt
					echo "Successfully copied new Image"
					ret=$SUCESS
					reboot
				else
					echo "Could not copy Kernel modules from /mnt"
					mount -o remount,rw /boot
					mount -o remount,rw /lib/modules
					umount /mnt
					ret=$ERROR
				fi		
			else
				echo "Cannot mount modules.img"
				echo "Remounting /boot Read only"
				mount -o remount,rw /boot
				mount -o remount,rw /lib/modules
				ret=$ERROR
			fi				
		else
			ret=$ERROR
			echo "Cannot remount /boot or /lib/modules"			
		fi
		## at bootup check version of kernel for upgrade status
		#gawk -i inplace -F" " -vOFS=" "  '$1=="check_version"{$2=$version}1;' ~/.bashrc		
	else
		echo "missing zImage"
		ret=$ERROR
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

