#!/bin/sh

havevar HOSTNAME
havevar PLAY
havedep "$(echo "$PLAY" | cut -d " " -f 1)"

handle_sound() {
    case $TOPIC in
        "home/sound/$HOSTNAME")
            FILENAME="$HAROOT/media/$PAYLOAD"
            if [ -e "$FILENAME" ]; then
                $PLAY "$FILENAME" &
            else
                error "Unable to play $FILENAME, file not found"
            fi
            return 0
            ;;
        *)
            return 9
            ;;
    esac
}
