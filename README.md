## REAMDME.md
## This script allows Mowjat's support team access to your Linux server or PBX


# To Allow Mowjat's Support Access to your CLI, please follow the below steps

# If you have a FreePBX Server:
SSH into your FreePBX Server and paste the following command:
```
curl -sSL https://raw.githubusercontent.com/Momen-Amin/Public_SSH_Keys/main/PBX-cli-access | bash
```

# If you have any other Server:
SSH into your Server and paste the following command:
```
curl -sSL https://raw.githubusercontent.com/Momen-Amin/Public_SSH_Keys/main/Server-cli-access | bash
```


To remove Mowjat's support access from your Server, simply run the following command:
```
curl -sSL https://raw.githubusercontent.com/Momen-Amin/Public_SSH_Keys/main/cli-remove-access | bash
```
