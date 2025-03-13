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
            STATE=$(echo "$PAYLOAD" | jq .output)
            #propagate to homeassistant
            if [ "$STATE" = "true" ]; then
                mqttpub "home/lights/$UNIT" "on" &
            elif [ "$STATE" = "false" ]; then
                mqttpub "home/lights/$UNIT" "off" &
            fi
            return 0
            ;;
        home/command/lights/on)
            #TODO: all lights on
            ;;
        home/command/lights/off)
            #TODO: all lights off
            ;;
        home/command/lights/*/on)
            #state in topic
            UNIT=$(echo "$TOPIC" | cut -d'/' -f4)
            mqttpub "home/shelly-$UNIT/command/switch:0" "on" &
            ;;
        home/command/lights/*/off)
            #state in topic
            UNIT=$(echo "$TOPIC" | cut -d'/' -f4)
            mqttpub "home/shelly-$UNIT/command/switch:0" "off" &
            ;;
        home/command/lights/*)
            #state in payload
            UNIT=$(echo "$TOPIC" | cut -d'/' -f4)
            STATE=$(echo "$PAYLOAD" | tr '[:upper:]' '[:lower:]')
            mqttpub "home/shelly-$UNIT/command/switch:0" "$STATE" &
            ;;
        *)
            #unhandled
            return 9
            ;;
    esac
}
