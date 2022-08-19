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
    if [ $ITERATIONS = "null" ]; then
        ITERATIONS=0
    fi
    sudo HAROOT=$HAROOT "$HAROOT/scripts/technofire/technofire.sh" --brightness "$BRIGHTNESS" --iter $ITERATIONS "$SCENE" &
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
            return 1
            ;;
    esac
}
