#!/bin/sh

handle_desktop() {
    case $TOPIC in
        "home/desktop/set/$HOSTNAME"|"home/kodi/$HOSTNAME")
            STATE=$(echo "$PAYLOAD" | tr '[:lower:]' '[:upper:]')
            if [ "$STATE" = "ON" ]; then
                pidof -q lightdm || sudo -n systemctl start display-manager &
            elif [ "$STATE" = "OFF" ]; then
                sudo -n systemctl stop display-manager &
            else
                #no state provided, determine and return state
                if pidof -q lightdm; then
                    STATE="ON"
                else
                    STATE="OFF"
                fi
            fi
            mqttpub "home/desktop/get/$HOSTNAME" "$STATE" &
            return 0
            ;;
        *)
            return 9
            ;;
    esac
}
