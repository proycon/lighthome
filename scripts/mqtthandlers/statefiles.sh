#!/bin/sh

#take care to run everything asynchronously from this point onward!

[ -e "$HASTATEDIR" ] && mkdir -p "$HASTATEDIR"
 
handle_statefiles() {
    case $TOPIC in
        "home/sensor/"*|"home/binary_sensor/"*)
            TYPE=$(echo "$TOPIC" | cut -d "/" -f 2)
            SENSOR=$(echo "$TOPIC" | cut -d "/" -f 3)
            [ ! -e "$HASTATEDIR/$TYPE" ] && mkdir -p "$HASTATEDIR/$TYPE"
            echo "$PAYLOAD" > "$HASTATEDIR/$TYPE/$SENSOR"
            return 0
            ;;
        "home/musicplayer/get/$HOSTNAME"|"home/kodi/get/$HOSTNAME")
            TYPE=$(echo "$TOPIC" | cut -d "/" -f 2)
            echo "$PAYLOAD" > "$HASTATEDIR/$TYPE/$HOSTNAME"
            ;;
        *)
            #unhandled
            return 9
            ;;
    esac
}
