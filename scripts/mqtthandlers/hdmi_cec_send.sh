#!/bin/sh

havedep cec-client
havevar DEVICE_CEC

handle_hdmi_cec_send() {
    case $TOPIC in
        "home/hdmi_cec_send/$HOSTNAME")
            "$HAROOT/scripts/media/hdmicecsend.sh" "$DEVICE_CEC" "$PAYLOAD" &
            return 0
            ;;
        *)
            return 9
            ;;
    esac
}
