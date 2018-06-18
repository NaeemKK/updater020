#!/usr/bin/env python
import requests
import sys
from requests.auth import HTTPBasicAuth
import json
payload = {"reboot" : True}
if (len(sys.argv) != 2):
	print("\n UUID is not provided");
	sys.exit(False); 

r = requests.put('https://localhost/v1.0/devices/'+ sys.argv[1], data=json.dumps(payload), verify=False)
result = json.loads(r.content)
print(result["success"]);
sys.exit(result["success"]);
