#!/bin/sh

havedep cec-client

handle_hdmi_cec_send() {
    case $TOPIC in
        "home/hdmi_cec_send/$HOSTNAME")
            "$HAROOT/scripts/media/hdmicecsend.sh" "/dev/cec1" "$PAYLOAD" &
            return 0
            ;;
        *)
            return 9
            ;;
    esac
}
