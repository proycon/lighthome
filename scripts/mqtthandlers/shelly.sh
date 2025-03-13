#!/bin/sh

#take care to run everything asynchronously from this point onward!

# - MQTT control must be enabled on the shelly
#    - TLS No validation
#    - RPC options do not have to be enabled
#    - Generic status update over MQTT must be on

havedep jq

handle_shelly() {
    case $TOPIC in
        home/shelly-*/status/switch:0)
            UNIT=$(echo "$TOPIC" | cut -d'/' -f2 | cut -d'-' -f2)
            STATE=$(cat "$PAYLOAD" | jq .output)
            #propagate to homeassistant
            if [ "$STATE" = "true" ]; then
                mqttpub "home/lights/$UNIT" "on" &
            elif [ "$STATE" = "false" ]; then
                mqttpub "home/lights/$UNIT" "off" &
            fi
            return 0
            ;;
        home/command/lights/*/on)
            UNIT=$(echo "$TOPIC" | cut -d'/' -f4)
            mqttpub "home/shelly-$UNIT/command/switch:0" "on" &
            ;;
        home/command/lights/*/off)
            UNIT=$(echo "$TOPIC" | cut -d'/' -f4)
            mqttpub "home/shelly-$UNIT/command/switch:0" "off" &
            ;;
        *)
            #unhandled
            return 9
            ;;
    esac
}
