#!/system/bin/env sh
#
# backfire: Fight FireStick TV with fire
#           I don't want to see ads. This $LAUNCHER is all I need,
#           simply kill default bloatware launcher when needed
#
# ps -A -f | grep [b]ackfire
# adb connect $HOST >/dev/null; adb shell "nohup sh /data/local/tmp/backfire.sh >/dev/null 2>&1 &"
#

# Launchers setup
# DEBUG=true
LAUNCHER="com.wolf.firelauncher"
AMAZON_LAUNCHER="com.amazon.tv.launcher"
LOG_FILE=/data/local/tmp/backfire.log

# Physical buttons remapping
BUTTON_AMAZON_MUSIC="org.xbmc.kodi/.Splash"
BUTTON_DISNEY_PLUS="org.xbmc.kodi/.Splash"
BUTTON_RECENTS=""


# Business logic, do not touch anything below
# --------------------------------------------------------------------------------------------
STRING_TOGGLER_LAUNCER="TOGGLER_LAUNCHER_EVENT"
STRING_AMAZON_LAUNCHER="Start proc.*$AMAZON_LAUNCHER"
debug() {
    if [[ -v DEBUG ]]; then
        DATE=$(date +%H:%m:%S)
        echo -e "\e[32m[debug] $DATE $1\e[0m"
        echo "$DATE $1" >> $LOG_FILE
    fi
}
start_launcher() {
    debug "[ ? ] Detect if $LAUNCHER is running"
    RUNNING=$(ps -A 2>&1 | grep $LAUNCHER)
    if [[ "$RUNNING" == "" ]]; then
        debug "        - Starting $LAUNCHER"
        am start $LAUNCHER
    else
        debug "        - $LAUNCHER is already running"
    fi
}

INSTANCES=$(pgrep -c -f "[b]ackfire.sh")
debug "[...] Starting script [$INSTANCES]"
if [ $INSTANCES -ne 1 ]; then
    debug "[EEE] This script is already running, aborting execution"
    exit 1
fi
start_launcher
rm -f $LOG_FILE
logcat --clear
CUSTOM_LAUNCHER=1
am crash $AMAZON_LAUNCHER
# endless while loop, kill default when needed
#   - fflush() for flushing stdout buffering or getevent will keep it until full buffering
(
    logcat -s ActivityManager:I TogglerLauncher:I *:S | awk '{ print; fflush() }' | grep --line-buffered -E "($STRING_AMAZON_LAUNCHER|$STRING_TOGGLER_LAUNCER)" &
    getevent -l | grep --line-buffered -E ".* DOWN" | awk '{ print $2" "$3; fflush() }'
) | while read -r LINE; do
        case "$LINE" in
            *"$STRING_TOGGLER_LAUNCER"*)
                CUSTOM_LAUNCHER=$((1 - CUSTOM_LAUNCHER))
                debug "[!!!] Custom Launcher Enabled = $CUSTOM_LAUNCHER"
                if [ $CUSTOM_LAUNCHER -eq 0 ]; then
                    am crash $LAUNCHER
                    am start $AMAZON_LAUNCHER
                else
                    am start $LAUNCHER
                    am crash $AMAZON_LAUNCHER
                fi
                ;;
            *"$AMAZON_LAUNCHER"*)
                if [ $CUSTOM_LAUNCHER -eq 1 ]; then
                    debug "[XXX] Amazon launcher detected, killing it"
                    am crash $AMAZON_LAUNCHER
                    start_launcher
                else
                    debug "[   ] Amazon launcher detected, ignoring it"
                fi
                ;;
            "EV_KEY "*)
                KEY=$(echo "$LINE" | awk '{ print $2 }')
                case "$KEY" in
                    "02ea")
                        # [Disney+] button -> $BUTTON_DISNEY_PLUS
                        am force-stop com.disney.disneyplus
                        debug "[KEY] Starting $BUTTON_DISNEY_PLUS"
                        am start "$BUTTON_DISNEY_PLUS"
                        ;;
                     "02eb")
                        # [Amazon Music] button -> $BUTTON_AMAZON_MUSIC
                        am force-stop com.amazon.bueller.music
                        debug "[KEY] Starting $BUTTON_AMAZON_MUSIC"
                        am start "$BUTTON_AMAZON_MUSIC"
                        ;;
                     "02ec")
                        # [Recents] button -> $BUTTON_RECENTS
                        # It's identified as launcher Activity, I'm already
                        #    killing it, there's no need to kill something
                        debug "[KEY] Starting $BUTTON_RECENTS"
                        am start "$BUTTON_RECENTS"
                        ;;
                    "KEY_HOMEPAGE")
                        debug "[KEY] Key detected: $KEY"
                        if [ $CUSTOM_LAUNCHER -eq 1 ]; then
                            debug "[KEY] $KEY: Amazon launcher detected, killing it"
                            am crash $AMAZON_LAUNCHER
                        fi
                        ;;
                    *)
                        debug "[KEY] Key detected: $KEY"
                        ;;
                esac
                ;;
            *)  
                debug "[***] $LINE"
                ;;
        esac
done
debug "[ERR] Application terminated"
# never reaching this point
