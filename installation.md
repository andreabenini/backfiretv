# Script installation procedure
let's keep it short, it's really not a big deal.  
- Android ADB (Android Debug Bridge) tools are required to perform this operation.
- Use [install.sh](install.sh) script or use it as a reference to basically copy and
  make the script `backfire.sh` executable on the Firestick side.


## Configuration part (optional)
It's possible to configure the script `backfire.sh` and its header section was exactly made for it.


## Disable other device features (optional)
Feel free to follow some advices or follow guide from 
[Firestick hacks](https://github.com/andreabenini/linux.tips/blob/main/android/firestick.amazon.md)
to turn off automatic powersaving or other annoying features usually provided with defauly values 
or enable usb storage back on older devices


### Debugging
Debugging logs are disabled by default, feel free to uncomment the line and declare the `$DEBUG`
variable. It's nice to enable it if you are mapping a new button not listed yet and you want
to see the associated source code. Usually turning on debugging means also to exec `backfire.sh`
from the adb command line to see log information, something like:
```sh
# Connect
adb connect $FIRESTICK
# Execute the entire shell
adb shell
# ...or in alternative just exec only the script
adb shell /data/local/tmp/backfire.sh
```
It's not a good idea to change the logfile path [`$LOG_FILE`], in that partition
it's usually possible to write files when needed, logs will be cleared on each boot.

### Buttons Remapping
- The top part of the script contains `Physical buttons remapping` section where you can change
    values for variables like: `BUTTON_*` listed
- Feel free to change buttons according to your needs
- A configurable button might assume two values
    - `""` Button is totally disabled, no further actions taken. default action will be removed
    - `"class.path/instance"` Disable the default action and execute the instance defined.  
        For example: `"org.xbmc.kodi/.Splash"` barely executes Kodi application
        - `org.xbmc.kodi` is the application ClassPath
        - `.Splash` is the Application instance to execute

### Launchers
- Amazon default launcher is defined in `$AMAZON_LAUNCHER` variable, there's no need to change it
- Your launcher can be defined in the `$LAUNCHER` variable. Default is 
    [Wolf Launcher](https://www.google.com/search?q=wolf+launcher): it's free, no ads or premium
    versions or annoying extra features. It's quite old but still good enough for the average user.
    Feel free to change it anytime with something else if you're using a different one.
