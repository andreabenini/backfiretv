# Script installation procedure
let's keep it short, it's really not a big deal.  
- Android ADB (Android Debug Bridge) tools are required to perform this operation
- Execute commands listed below or create a simple script as I did:
```sh
    # your firestick, the script, firestick remote path
    FIRESTICK=yourDevice            # IP address or name of the firestick, up to you

    SCRIPT=backfire.sh              # script name, LEAVE IT AS IT IS
    FILEPATH=/data/local/tmp        # Installation path on FirestickTV, LEAVE IT AS IT IS.

    # Connect to your device (adb is required, setting on the device: debugging=on)
    adb connect $FIRESTICK

    # Download the script, make it executable
    adb push $SCRIPT $FILEPATH/             && \
    adb shell chmod 755 $FILEPATH/$SCRIPT

    # If you want to manually start it just for testing:
    #     "adb shell $FILEPATH/$SCRIPT"
```
