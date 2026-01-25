#!/usr/bin/env bash
#
# Install BackfireTV script in the device
#

SCRIPT=backfire.sh
FILEPATH=/data/local/tmp
if [ "$1" == "" ]; then
    echo -e "\nUsage: $0 <deviceName>"
    echo -e "       Install $SCRIPT in the <deviceName> firestick\n"
    exit 1
fi
FIRESTICK=$1

echo -e "\n- Connecting to $FIRESTICK..."
adb connect $FIRESTICK
if [ $? -ne 0 ]; then
    echo -e "ERROR: Cannot connect to $FIRESTICK, aborting script"
    echo -e "       Fix connection issues before reinstalling this script"
    exit 1
fi

echo -e "\n- Installing $SCRIPT in $FILEPATH for [$FIRESTICK]"
adb push $SCRIPT $FILEPATH && \
adb shell chmod 755 $FILEPATH/$SCRIPT

echo -e "\n- Installation completed, now reboot [$FIRESTICK] to apply changes\n"

