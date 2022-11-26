#!/bin/sh

#take care to run everything asynchronously from this point onward!

havedep jq

run_technofire() {
    if [ "$SCENE" = "off" ]; then
        STATE="OFF"
    else
        STATE="ON"
    fi
    mqttpub "home/technofire/$HOSTNAME/state" "$STATE" & #feedback
    #sudo must be set up to allow passwordless access for technofire.sh
    if [ -z "$ITERATIONS" ] || [ $ITERATIONS = "null" ]; then
        ITERATIONS=0
    fi
    if [ -z "$LEDS" ]; then
        if [ "$HOSTNAME" = "pi4" ]; then
            LEDS=60
        else
            LEDS=30
        fi
    fi
    info "Calling technofire.sh --brightness \"$BRIGHTNESS\" --iter $ITERATIONS --leds $LEDS \"$SCENE\""
    sudo HAROOT=$HAROOT "$HAROOT/scripts/technofire/technofire.sh" --brightness "$BRIGHTNESS" --iter $ITERATIONS --leds $LEDS "$SCENE" &
}

handle_technofire() {
    case $TOPIC in
        "home/technofire/$HOSTNAME/set/"*)
            SCENE=$(echo "$TOPIC" | cut -d'/' -f5 | tr " " "_" | tr "[:upper:]" "[:lower:]")
            [ "$PAYLOAD" = "OFF" ] && SCENE="off"
            BRIGHTNESS=$(echo "$TOPIC" | cut -d'/' -f6 | tr -d '"')
            ITERATIONS=0
            run_technofire
            return 0
            ;;
        "home/technofire/$HOSTNAME/jsonset")
            SCENE=$(echo "$PAYLOAD" | jq '.scene' | tr -d '"' | tr " " "_" | tr "[:upper:]" "[:lower:]")
            [ "$PAYLOAD" = "OFF" ] && SCENE="off"
            BRIGHTNESS=$(echo "$PAYLOAD" | jq '.brightness' | tr -d '"' )
            ITERATIONS=$(echo "$PAYLOAD" | jq '.iterations' | tr -d '"' )
            run_technofire
            return 0
            ;;
        *)
            return 9
            ;;
    esac
}
