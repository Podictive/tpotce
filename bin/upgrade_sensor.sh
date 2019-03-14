#!/bin/bash
# Upgrade a sensor to a monitored sensor with an external elasticsearch
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
myBACKTITLE="TPOT - UPGRADE SENSOR"

if [ "$(readlink -f /opt/tpot/etc/tpot.yml)" != "/opt/tpot/etc/compose/sensor.yml" ] || \
        "$(readlink -f /opt/tpot/etc/tpot.yml)" != "/opt/tpot/etc/compose/reporting_sensor.yml" ]; then
    dialog --keep-window --backtitle "$myBACKTITLE" --title "[ NOT OK ]" \
            --msgbox "\nCurrently not installed as a sensor.\nRecommended to reinstall as sensor.\n\nPress CTRL-C to cancel." 7 47
fi

if [ ! -f "/data/elk/certificates/ca.pem" ]; then
    dialog --keep-window --backtitle "$myBACKTITLE" --title "[ NOT OK ]" \
            --msgbox "\nError: Missing ca.pem. Please run addsensor.sh on the receiving server first\n" 7 47
    exit 0
else
        dialog --keep-window --backtitle "$myBACKTITLE" --title "[ REPORTING SENSOR ]" \
            --msgbox "\nYou need the generated username/password from addsensor.sh on the receiving server. " 7 47
fi

es_target=$(dialog --keep-window --backtitle "$myBACKTITLE" \
                --title "[ Enter the elasticsearch target ]" \
                --inputbox "\nElasticsearch URL (e.g. 203.0.113.137:64297/es/)" 9 50 3>&1 1>&2 2>&3 3>&-)

es_username=$(dialog --keep-window --backtitle "$myBACKTITLE" \
                --title "[ Enter logstash username ]" \
                --inputbox "\nUsername (generated via addsensor.sh)" 9 50 3>&1 1>&2 2>&3 3>&-)

es_password=$(dialog --keep-window --insecure --backtitle "$myBACKTITLE" \
                 --title "[ Enter logstsash password ]" \
                 --passwordbox "\nPassword (generated via addsensor.sh)" 9 60 3>&1 1>&2 2>&3 3>&-)

echo "ES_LOGSTASH_TARGET=${es_target}"  > /opt/tpot/etc/compose/es_logstash
echo "ES_LOGSTASH_USER=${es_username}"  >> /opt/tpot/etc/compose/es_logstash
echo "ES_LOGSTASH_PW=${es_password}"  >> /opt/tpot/etc/compose/es_logstash

fuBANNER "REPORTING SENSOR"
echo "Wrote the following configuration:"
cat /opt/tpot/etc/compose/es_logstash

echo "Changing sensor to reporting sensor"
rm -f /opt/tpot/etc/tpot.yml
ln -s /opt/tpot/etc/compose/reporting_sensor.yml /opt/tpot/etc/tpot.yml

fuBANNER "STARTING SENSOR"
docker-compose -f /opt/tpot/etc/tpot.yml up -d

fuBANNER "DONE"
echo "Please check the logfile of logstash if it's working."
echo "Or ask on the forum for help."
docker-compose -f /opt/tpot/etc/tpot.yml logs -f logstash
