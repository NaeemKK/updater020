#!/bin/bash
set -x
read -p "Enter Package Name without extension i.e. [.tar.xz] : " package_name
read -p "Enter Version Number : " version_number
echo ""
echo "[------------- Creating Package -------------]"
rm package.json > /dev/null
jq -n --arg package_name "$package_name" '{package_name: $package_name}' > package.json
if [ $? -ne 0 ]
then
	echo "Failed to create package.json"
else
	echo "Check package.json for successfull creation"	
fi	
tar -cJf "$package_name"_"$version_number".tar.xz $package_name.tar.xz.sha256.base64 updater.sh sign_in.crt package.json $package_name.tar.xz

if [ $? -ne 0 ]
then
	echo "Failed"
	exit -1
fi
	
echo ""
echo "[------------- Upload the "$package_name"_"$version_number".tar.xz to cloud -------------]"
echo ""
