#!/bin/sh

#take care to run everything asynchronously from this point onward!

havedep jq

handle_irsend() {
    case $TOPIC in
        "home/irsend/$HOSTNAME"|"home/ir_send/$HOSTNAME")
            DEVICE=$(echo "$PAYLOAD" | jq '.device' | tr -d '"')
            KEY=$(echo "$PAYLOAD" | jq '.key' | tr -d '"')
            "$HAROOT/scripts/media/irsend.sh" "$DEVICE" "$KEY" &
            return 0
            ;;
        *)
            #unhandled
            return 9
            ;;
    esac
}
