#!/bin/bash
echo ""
echo "[---------------- Enter Private Key to sign packages ----------------]"
echo ""

openssl req -newkey rsa:2048 -keyout sign_in.key -out crt_sig_req.csr
if [ $? -ne 0 ]
then
	exit -1
fi
echo ""
echo "[---------------- Enter Private Key for CA certificate ----------------]"
echo ""

openssl req -new -x509 -days 365 -keyout ca.key -out ca.crt
if [ $? -ne 0 ]
then
	exit -1
fi
	
echo ""
echo "[---------------- Now we need to sign the “crt_sig_req.csr” with our CA certificate credentials to create certificate that will be sent along with our OTA package  ----------------]"
echo ""

openssl x509 -req -in crt_sig_req.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out sign_in.crt -days 365
if [ $? -ne 0 ]
then
	exit -1
fi

echo ""
echo "[---------------- Success ----------------]"
echo ""
echo ""
echo "[---------------- Cleaning ---------------]"
rm crt_sig_req.csr ca.srl 2> /dev/null
echo ""
echo "Now place ca.crt on each Gateway device. After placing it, you can sign a package with your sign_in.key and send it to the device along with sign_in.crt."


cp ca.crt /root/

sleep 1

##### Sign Package ###########
echo ""
echo "[------------- Signing Package--------------]"
echo ""

read -p "Enter Package Name : " package_name

if [ ! -e $package_name ]
then
	echo "No such package found"
	exit -1	
fi	
	
echo ""
echo "[------------- Creating Digest and Signature of OTA Package--------------]"
echo ""

openssl dgst -sha256 -sign sign_in.key -out $package_name.sha256 $package_name
if [ $? -eq 1 ]
then
	exit -1
fi

echo ""
echo "[------------- Encoding --------------]"
echo ""
openssl enc -base64 -in $package_name.sha256 -out $package_name.sha256.base64
if [ $? -eq 1 ]
then
	exit -1
fi

echo ""
echo "[-------------- Success --------------]"
echo ""

echo "Cleaning files"
rm  $package_name.sha256 2> /dev/null

echo "$package_name.sha256.base64 Created"

#################################### Craete Signed Package ####################
echo ""
echo "[------------- Creating Package to be uploaded to the cloud --------------]"
echo ""
read -p "Enter Package Name without extension i.e. [.tar.xz] : " package_name
read -p "Enter Version Number : " version_number
echo ""
echo "[------------- Creating Package -------------]"
echo ""

if [ ! -e updater.sh ]
then
	echo "No updater.sh found"
	exit -1
fi
		
rm package.json 2> /dev/null
jq -n --arg package_name "$package_name" '{package_name: $package_name}' > package.json
if [ $? -ne 0 ]
then
	echo "Failed to create package.json"
else
	echo "package.json successfully created"	
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

