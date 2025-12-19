#!/bin/sh

#all automations are invoked asynchronously by statefiles and receive three parameters
# $1 - current payload (full)
# $2 - previous payload (one line only)
# $3 - last changed value (before current invocation)

# functions are never invoked when a previous same one is still running
# _cleanup variants are invoked afterward but do not block new triggers

havedep matty
havedep mpc


binary_sensor_doorbell() {
    case $1 in
        on|ON|On|true|True|open|OPEN|1)
            if [ "$3" = "" ] || [ "$3" -gt 5 ]; then
                playsound doorbell.ogg &
                PID1=$?
                yellow_notification_lights &
                PID2=$?
                mqttpub "home/sound/everywhere" "doorbell.ogg" &
                mpc pause
                matty "$MATRIX_ROOM" "Doorbell rang" &
                #wait to ensure this automation can't be triggered twice at the same time
                wait $PID1 $PID2
            fi
            ;;
    esac
}

binary_sensor_doorbell_cleanup() {
    sleep 30
    reset_notification_lights
}

