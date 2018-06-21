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
rm crt_sig_req ca.srl > /dev/null
echo ""
echo "Now place ca.crt on each Gateway device. After placing it, you can sign a package with your sign_in.key and send it to the device along with sign_in.crt."


