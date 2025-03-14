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
            case $STATE in
                on|ON|true|True|TRUE|1)
                    mqttpub "home/lights/$UNIT" "on" &
                    ;;
                off|OFF|false|False|FALSE|0)
                    mqttpub "home/lights/$UNIT" "off" &
                    ;;
            esac
            return 0
            ;;
        home/command/lights/status)
            #Request status update from all lights
            for UNIT in tv_spots back_corner back_room office midspots hall front_room porch garden balcony; do
                mqttpub "home/shelly-$UNIT/command" "status_update" 
            done &
            ;;
        home/command/lights/on)
            #TODO: all lights on (currently handled by homeassistant)
            ;;
        home/command/lights/off)
            #TODO: all lights off (currently handled by homeassistant)
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
            case $PAYLOAD in
                on|ON|true|True|TRUE|1)
                    mqttpub "home/shelly-$UNIT/command/switch:0" "on" &
                    ;;
                off|OFF|false|False|FALSE|0)
                    mqttpub "home/shelly-$UNIT/command/switch:0" "off" &
                    ;;
            esac
            ;;
        *)
            #unhandled
            return 9
            ;;
    esac
}
