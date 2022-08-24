#!/bin/bash
# Run as root
# /home/sshuttle/conncheck.sh
## replace 'root' user with any user that has global SSH access to servers
##host file must include IP Adressess that you want to check
file=/home/script/hosts
ncat_port=22
RED='\033[1;31m'
GREEN='\033[1;32m'
NC='\033[0m'  # no color
bold=$(tput bold)
clear=$(tput sgr0)
RESULT=result.txt
if [ -f result.txt ]
then
   echo
else
    touch /home/script/$RESULT
fi
## check if netcat is installed
if (type nc 2>&1 >/dev/null)
then
    echo "netcat is installed, proceeding.."
else
    echo -e "${RED}[ERROR]${NC} netcat is not installed on this host"
    exit 1
fi


while read -r line
do
    if [[ -n $line ]] && [[ "${line}" != \* ]]
    then
        ip=$(echo $line | awk '{print $1}')
        hostname=$(echo $line | awk '{print $2}')

        ## if ipv4
        if [[ $ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            echo "--------------------------------------"

            ## check netcat connectivity
            if (nc -z -w 2 $ip $ncat_port 2>&1 >/dev/null)
            then
                ncat_status="nc OK"
                echo "${hostname} (${ip}): ${ncat_status} " >> $RESULT
            else
                netcat_status2="nc ERROR"
                echo "${hostname} (${ip}): ${netcat_status2} " >> $RESULT

            fi


            ## attempt ssh connection, get exit code
            ssh -o ConnectTimeout=3 \
            -o "StrictHostKeyChecking no" \
            -o BatchMode=yes \
            -i /root/.ssh/id_rsa \
            -q root@"${ip}" exit </dev/null
            if [ $? -eq 0 ]
            then
                ssh_status="ssh OK"

            else
                ssh_status="${bold}ssh ERROR${clear}"
            fi
                    echo "${hostname} (${ip}): ${ncat_status} | ${ssh_status}" >> $RESULT
        fi
    fi

done < "${file}"
