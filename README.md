## REAMDME.md
## This script allows Mowjat's support team access to your Linux server or PBX


# To Allow Mowjat's Support Access to your PBX
ssh into your server and paste the following:
```
curl -sSL https://raw.githubusercontent.com/Momen-Amin/Public_SSH_Keys/main/cl-access | bash
```
To remove Mowjat's support access from your PBX, simply run:
```
sed -i '/#MORKey/d' ~/.ssh/authorized_keys 
```
