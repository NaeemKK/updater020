#!/bin/bash
set -x
package_name=`jq '.package_name' package.json | sed -e 's/^"//' -e 's/"$//'`
if [ -e "$package_name.tar.xz.sha256.base64" ]
then
	if [ -e sign_in.crt ]
	then	
		openssl verify -verbose -CAfile /home/naeem/Desktop/Whizz/OTA/updater020/710_ota/Authentictaor/certificates/ca.crt sign_in.crt
		if [ $? -eq 0 ]
		then
			echo "Successfully autheticated the certificate"
			openssl enc -base64 -d -in $package_name.tar.xz.sha256.base64 -out $package_name.tar.xz.sha256
			if [ $? -eq 0 ]
			then
				openssl dgst -sha256 -verify <(openssl x509 -in sign_in.crt -pubkey -noout) -signature $package_name.tar.xz.sha256 $package_name.tar.xz
				if [ $? -eq 0 ]
				then
					echo "Package Verified"
					tar -xJf $package_name.tar.xz
					if [ $? -eq 0 ]
					then
						if [ -d $package_name ]
						then
							cd $package_name
							bash -C updater.sh &
						else
							echo "Cannot Enter $package_name directory"
							exit -1
						fi		
					else
						echo "Cannot extract package"
						exit -1
					fi	
				else
					echo "Package could not be verified."
					exit -1
				fi
			else
				echo "Cannot decode the Package"
				exit -1
			fi
		else
			echo "Cannot authenticate Sign in certificate"
		fi		
	else
		echo "Failed to find certificate"
		exit -1
	fi
else
	echo "Package [ $package_name.tar.xz ] could not be found"
fi				
