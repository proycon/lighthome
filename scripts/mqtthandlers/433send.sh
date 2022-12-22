#!/bin/sh

#take care to run everything asynchronously from this point onward!

havevar GPIO_PIN_433SEND

handle_433send() {
    case $TOPIC in
        "home/433send/set/$HOSTNAME/"*)
            PROTOCOL=$(echo "$TOPIC" | cut -d'/' -f5)
            GROUP=$(echo "$TOPIC" | cut -d'/' -f6)
            UNIT=$(echo "$TOPIC" | cut -d'/' -f7)
            STATE=$(echo "$PAYLOAD" | tr '[:upper:]' '[:lower:]')
            #perform the action (asynchronously)
            (
                if "$HAROOT/scripts/switch/433send.sh" "$GPIO_PIN_433SEND" "$PROTOCOL" "$GROUP" "$UNIT" "$STATE"; then
                    #and send confirmation back to the broker
                    STATE=$(echo "$STATE" | tr '[:lower:]' '[:upper:]')
                    mqttpub "home/433send/get/$PROTOCOL/$GROUP/$UNIT" "$STATE"
                else
                    error "433send failed: $HAROOT/scripts/switch/433send.sh $GPIO_PIN_433SEND $PROTOCOL $GROUP $UNIT $STATE"
                fi
                case "$PROTOCOL/$GROUP/$UNIT" in
                     elro/31/E)
                        mqttpub "home/lights/tv_spots" "$STATE"
                        ;;
                     elro/15/A)
                        mqttpub "home/lights/office" "$STATE"
                        ;;
                     oldkaku/M/10)
                        mqttpub "home/lights/front_room" "$STATE"
                        ;;
                     elro/31/B)
                        mqttpub "home/lights/midspots" "$STATE"
                        ;;
                     elro/31/A)
                        mqttpub "home/lights/back_room" "$STATE"
                        ;;
                     elro/31/C)
                        mqttpub "home/lights/back_corner" "$STATE"
                        ;;
                     newkaku/120/7)
                        mqttpub "home/lights/kitchen" "$STATE" #old
                        ;;
                     newkaku/120/8)
                        mqttpub "home/lights/kitchen" "$STATE" #new
                        ;;
                     elro/15/C)
                        mqttpub "home/lights/bedroom" "$STATE"
                        ;;
                     elro/23/A)
                        mqttpub "home/lights/garden" "$STATE"
                        ;;
                     newkaku/121/9)
                        mqttpub "home/lights/balcony" "$STATE"
                        ;;
                     elro/15/B)
                        mqttpub "home/lights/hall" "$STATE"
                        ;;
                     newkaku/121/8)
                        mqttpub "home/lights/roof" "$STATE"
                        ;;
                     oldkaku/M/11)
                        mqttpub "home/lights/porch" "$STATE"
                        ;;
                     newkaku/121/7)
                        mqttpub "home/bathroom_vent" "$STATE"
                        ;;
                esac
            ) &
            return 0
            ;;
        *)
            #unhandled
            return 9
            ;;
    esac
}
