#!/bin/bash
# Start the process of adding a new sensor to tpot
source /etc/environment
set -e

# Create banners
function fuBANNER {
  toilet -f ivrit "$1"
}

# Do we have root?
function fuGOT_ROOT {
echo
echo -n "### Checking for root: "
if [ "$(whoami)" != "root" ];
  then
    echo "[ NOT OK ]"
    echo "### Please run as root."
    echo "### Example: sudo $0"
    exit
  else
    echo "[ OK ]"
fi
}

function fuCHECK_ES_RUNNING {
    isrunning=$(docker inspect -f '{{.State.Running}}' elasticsearch)
    if [ $? -eq 0 ] && [ "${isrunning}" == "true" ]; then
        return true
    else
        return false
    fi
}

myBACKTITLE="TPOT - ADD SENSOR"



if [ "$(readlink -f /opt/tpot/etc/tpot.yml)" == "/opt/tpot/etc/compose/sensor.yml" ] || \
        "$(readlink -f /opt/tpot/etc/tpot.yml)" == "/opt/tpot/etc/compose/reporting_sensor.yml" ]; then
    dialog --keep-window --backtitle "$myBACKTITLE" --title "[ NOT OK ]" \
            --msgbox "\nCurrently installed as a sensor.\nCannot continue: you need to reinstall with ELK-stack.\nDid you mean to run upgrade_sensor.sh instead?" 7 47
    exit 1
fi

dialog --keep-window --backtitle "$myBACKTITLE" --title "Read this carefully" \
        --msgbox "We're going to add a new user to your elasticsearch instance.
This means we have to make your elasticsearch directly accessible for the other sensors.
You do this preferably through a LAN or VPN. 
You have to configure this yourself first." 10 70

dialog --keep-window --backtitle "$myBACKTITLE" --title "Read this carefully" \
        --msgbox "Keep in mind; being an elk-stack is a hard life.
Receiving and processing honeypot information from multiple tpot-installations may
require too much processing power for a single node. 
At the moment, unfortunately, there's no documentation available how to
upgrade your elk-stack to a multinode setup. 
" 10 70


if ! fuCHECK_ES_RUNNING; then
    dialog --keep-window --backtitle "$myBACKTITLE" --title "[ NOT OK ]" \
            --msgbox "\nElasticsearch is not running. Please start (or reboot) your tpot. " 7 47
#    exit 2
fi

ips="$(hostname -I) $(/opt/tpot/bin/myip.sh)"
options=""
for ip in ${ips}; do
  options="${options} ${ip} ${ip} OFF"
done
echo ${options}

listen_addresses=$(dialog --keep-window --backtitle "$myBACKTITLE" \
            --title "Listen addresses" --checklist 'Which IP-addresses should elasticsearch listen on' 300 300 20 ${options} 3>&1 1>&2 2>&3 3>&-)

# Write these into tpot.override.yml?
base="
version: '2.3'

services:
  elasticsearch:
    ports:
"

for ip in ${listen_addresses}; do
     base+="     - ${ip}:64221:9200
"
done
echo "${base}" > /opt/tpot/etc/tpot.override.yml

while true; do
    sensorname=$(dialog --keep-window --backtitle "$myBACKTITLE" \
                    --title "Enter identifier for the sensor" \
                    --inputbox "\nAdd identifier name (e.g. sensor-us-nc1)" 9 50 3>&1 1>&2 2>&3 3>&-)


    logstashpassword=`tr -cd '[:alnum:]' < /dev/urandom | fold -w30 | head -n1`
    bcrypt_logstashpassword=`python -c "from passlib.hash import bcrypt;print bcrypt.hash('${logstashpassword}')"`

    if grep -iq "${sensorname}" /opt/tpot/etc/sgconfig/sg_internal_users.yml; then
        dialog --keep-window --backtitle "$myBACKTITLE" --title "Sensorname already in use" \
            --msgbox "\nThe sensorname is already in use. Please enter a different username. " 7 47
    else
        break
    fi
done

sgconfig="
${sensorname}:  
  hash: ${bcrypt_logstashpassword}
  roles:
    - logstash
"

echo "$sgconfig" >> /opt/tpot/etc/sgconfig/sg_internal_users.yml

/opt/tpot/bin/tools/sgadmin.sh -cd /opt/tpot/etc/sgconfig -icl -nhnv  -p64410 \
       -cacert /data/elk/certificates/ca.pem \
       -cert /data/elk/certificates/tsec.pem \
       -key /data/elk/certificates/tsec.key

/bin/bash -c "cd /opt/tpot/etc &&  docker-compose -f tpot.yml -f tpot.override.yml up -d "


dialog --keep-window --backtitle "$myBACKTITLE" --title "Read this carefully" \
        --msgbox "New user added and elasticsearch is restarting. Press OK for further instructions" 10 70


fuBANNER "FINALIZE"

echo "CA-Certificate"
echo "Please place the following CA-Certificate file in "
echo "/data/elk/certificates/ca.pem: ":
cat /data/elk/certificates/ca.pem

echo 
echo
echo "After, start /opt/tpot/bin/upgrade_sensor.sh and follow the instructions"
echo "You will need the following info:"
echo
echo "Username: ${sensorname}" 
echo "Password: ${logstashpassword}"
echo 
echo "Cheers"
