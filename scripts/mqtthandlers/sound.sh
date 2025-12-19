#!/bin/sh

havevar HOSTNAME
havevar PLAY
havedep "$(echo "$PLAY" | cut -d " " -f 1)"

handle_sound() {
    case $TOPIC in
        "home/sound/$HOSTNAME"|"home/sound/all"|"home/sound/everywhere")
            playsound "$PAYLOAD" &
            return 0
            ;;
        *)
            return 9
            ;;
    esac
}
