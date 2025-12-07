#!/bin/bash
#
# @description      dnsmasq lease hook action
#                   Started on every dhcp lease, it's used for sending initial event to the firestick
#                   Once spawned the command it will be automatically released
# @author           Andrea Benini
# @date             2025-12
# @version          1.0
# @history          1.0     First working version, taking dnsmasq official docs and fix input parameters
#                           According to their specs
#
# @see              This is the basic syntax taken from official DNSMASQ documentation
#                   The 4 arguments are:
#                       $1 = action (add, del, old)
#                            add - add a new host to the lease
#                            del - delete a host from the lease
#                            old - update an available host in the lease
#                       $2 = MAC address
#                       $3 = IP address
#                       $4 = Hostname (if available)
ACTION=$1
MAC=$2
IP=$3
HOSTNAME=$4
declare -A firestick_delay


# Configuration Part
# ----------------------------------------------------
# Firestick devices
firestick_devices=("device1" "device2" "device3")
# default delay for all devices
firestick_delayDefault=15
# custom delay defined per single host, if needed (like because it's a slow/old one)
firestick_delay_device2=20



# business logic, do not touch anything below
# ----------------------------------------------------

# Required utilities to execute this script
required_tools=("adb")

# Log all events to a dedicated file
LOG_FILE="/tmp/dnsmasq_leases.log"
TIMESTAMP=$(date)

# Initial requirements checks
for tool in "${required_tools[@]}"; do
    if [ "$(which $tool 2>/dev/null)" == "" ]; then
        echo "ERROR: Aborting script, required tool: '$tool' not found"
        exit 1
    fi
done
# Log everything
echo "> $TIMESTAMP  [$ACTION]  $MAC -> $IP [$HOSTNAME]" >> $LOG_FILE

# working on firestick devices
for host in "${firestick_devices[@]}"; do
    if [ "$host" == "$HOSTNAME" ] && [ "$ACTION" != "del" ]; then
        # [add] renewed lease, [old] updated lease.  Sideloading launcher injection
        eval "host_delay=\"\$firestick_delay_${host}\""
        if [ "$host_delay" = "" ]; then
            host_delay=$firestick_delayDefault
        fi
        echo -n ">                                      Firestick TV detected, hacking it with custom launcher (delay:$host_delay)" >> $LOG_FILE
        sleep $host_delay
        echo " [started]" >> $LOG_FILE
        adb connect $host >/dev/null
        adb shell "nohup sh /data/local/tmp/backfire.sh >/dev/null 2>&1 &"
    fi
done
# Prune log file to keep just last 100 lines
tail -n 100 $LOG_FILE > ${LOG_FILE}.tmp && mv ${LOG_FILE}.tmp $LOG_FILE

exit 0

