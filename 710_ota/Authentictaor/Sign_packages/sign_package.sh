#!/bin/bash

if [ $# -lt 1 ]
then
	echo "Enter Package Name as an argument"
	exit -1
fi

if [ ! -e $1 ]
then
	echo "No such package found"
	exit -1
fi

	
echo ""
echo "[------------- Creating Digest and Signature of OTA Package--------------]"
echo ""

openssl dgst -sha256 -sign sign_in.key -out $1.sha256 $1
if [ $? -eq 1 ]
then
	exit 0
fi

echo ""
echo "[------------- Encoding --------------]"
echo ""
openssl enc -base64 -in $1.sha256 -out $1.sha256.base64
if [ $? -eq 1 ]
then
	exit 0
fi

echo ""
echo "[------------- Success --------------]"
echo ""

echo "Cleaning files"
rm  $1.sha256 2> /dev/null

echo "Now $1.sha256.base64 can be sent"
