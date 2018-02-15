#!/bin/bash

ERROR_UPDATER_DEVICE_COMMUNICATION=4

if [ -f "log1" ]
then
	rm log1
fi
if [ -f "log2" ]
then
	rm log2
fi

function get_version()
{ 
	local count=0  
	local char_val="" 
	local version="" 
	declare -i int_val ## declare int 
	for value in $1 
	do 
		int_val=$value 
		char_val="$(echo $int_val | awk '{printf "%c\n", $1}')" ## hex to char 
		version=$version$char_val ## concatination of old and new
	done
	echo $version
}

coproc bluetoothctl
echo -e "scan on" >&${COPROC[1]}
sleep 2
echo -e "scan off"\nexit" >&${COPROC[1]}
sleep 2
output=$(cat <&${COPROC[0]})
if [ -z "$(echo "$output" | grep "Device $1")" ];then
        echo "Device not Found"
        #send error code RET
	RET=$ERROR_UPDATER_DEVICE_COMMUNICATION	
	exit $RET
else
        echo "Device found"
        coproc bluetoothctl
	echo -e "scan on">&${COPROC[1]}
        sleep 2
	echo -e "scan off">&${COPROC[1]}
        sleep 2
	echo -e "connect "$1"">&${COPROC[1]}
        sleep 4
        echo -e "list-attributes">&${COPROC[1]}
        sleep 2
        echo -e "disconnect">&${COPROC[1]}
        sleep 4
        echo -e "exit">&${COPROC[1]}
        output=$(cat <&${COPROC[0]})
        echo "$output" > log1
        fr_attr="$(sed -n '/Firmware Revision String/{x;p;d;}; x' log1 | sed -n 2p | tr -d [:blank:])" ## get attribute of firmware revision
        echo "$fr_attr"
        coproc bluetoothctl
        echo -e "connect "$1"">&${COPROC[1]}
        sleep 4
        #echo -e "list-attributes">&${COPROC[1]}
        echo -e "select-attribute $fr_attr">&${COPROC[1]}
        sleep 1
        echo -e "read">&${COPROC[1]}
        echo -e "exit">&${COPROC[1]}
        output=$(cat <&${COPROC[0]})
        echo "$output" > log2
	if [ ! -z "$(cat log2 | grep "No device connected")" ];then
		echo "Device cannot be connected"
		RET=$ERROR_UPDATER_DEVICE_COMMUNICATION
		exit $RET
	fi
	version_str="Attribute $fr_attr Value:" ##  strings of version number
	fversion_strings="$(cat log2 | grep "$version_str")" #filter only version strings
	fversion_strings="$(echo "$fversion_strings" | awk -F: '{print $NF}' | tr -d [:blank:])" 
	version="$(get_version "$fversion_strings")"
	echo "version is $version" 
fi



./updater-app "$1" "$version"
RET=$?
exit $RET

