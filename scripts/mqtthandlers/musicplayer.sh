#!/bin/sh

havedep snapclient
havedep mpc

handle_musicplayer() {
    case $TOPIC in
        "home/musicplayer/set/$HOSTNAME"|"home/musicplayer/$HOSTNAME")
            STATE=$(echo "$PAYLOAD" | tr '[:lower:]' '[:upper:]')
            if [ "$STATE" = "ON" ]; then
                if ! mpc -q status; then
                    mqtt_say "$HOSTNAME" "Error: Unable to connect to music player" &
                    return 1
                fi
                if [ "$(mpc playlist | wc -l)" = "0" ]; then
                    #empty playlist, load the default
                    if ! mpc search filename "$DEFAULT_MPC_SEARCH" | mpc add; then
                        mqtt_say "$HOSTNAME" "Error: Unable to find and add default songs" &
                        return 1
                    fi
                fi
                mpc play #no-op when already playing
                killall snapclient
                (
                    if ! snapclient -s "${SNAPCAST_SOUNDCARD:-default}" -h anaproy.nl; then
                        mqtt_say "$HOSTNAME" "Error: Music streamer failed"
                    else
                        mqtt_say "$HOSTNAME" "Music streamer finished"
                    fi
                    mqttpub "home/musicplayer/get/$HOSTNAME" "OFF"
                ) &
            elif [ "$STATE" = "OFF" ]; then
                killall snapclient &
            else
                #no state provided, determine and return state
                if pidof -q snapclient; then
                    STATE="ON"
                else
                    STATE="OFF"
                fi
            fi
            mqttpub "home/musicplayer/get/$HOSTNAME" "$STATE" &
            return 0
            ;;
        *)
            return 9
            ;;
    esac
}
