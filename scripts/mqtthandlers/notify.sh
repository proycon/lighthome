#!/bin/sh

havevar HOSTNAME
havevar PLAY
havedep notify-send

handle_notify() {
    case $TOPIC in
        "home/notify/$HOSTNAME"|"home/notify/everywhere")
            notify-send "Home Automation" "$PAYLOAD"
            return 0
            ;;
        *)
            return 9
            ;;
    esac
}
