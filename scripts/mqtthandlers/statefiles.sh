#!/bin/sh

#take care to run everything asynchronously from this point onward!

[ ! -e "$HASTATEDIR" ] && mkdir -p "$HASTATEDIR"
 
handle_statefiles() {
    case $TOPIC in
        "home/sensor/"*|"home/binary_sensor/"*|"home/lights/"*|"home/presence/"*|"home/climate/"*)
            TYPE=$(echo "$TOPIC" | cut -d "/" -f 2)
            SENSOR=$(echo "$TOPIC" | cut -d "/" -f 3)
            writestate "$TYPE/$SENSOR" "$PAYLOAD"
            return 0
            ;;
        "home/alarm")
            SENSOR=$(echo "$TOPIC" | cut -d "/" -f 2)
            writestate "$SENSOR" "$PAYLOAD"
            return 0
            ;;
        "home/musicplayer/get/$HOSTNAME"|"home/kodi/get/$HOSTNAME")
            TYPE=$(echo "$TOPIC" | cut -d "/" -f 2)
            writestate "$TYPE/$HOSTNAME" "$PAYLOAD"
            return 0
            ;;
        *)
            #unhandled
            return 9
            ;;
    esac
}
