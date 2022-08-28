#!/bin/sh

#take care to run everything asynchronously from this point onward!

havevar HOSTNAME
havevar PLAY
havedep "$(echo "$PLAY" | cut -d " " -f 1)"

handle_tts() {
    case $TOPIC in
        "home/say/$HOSTNAME"|"home/say/all"|"home/say/everywhere")
            "$HAROOT/scripts/voice/picotts.sh" "$PAYLOAD" &
            return 0
            ;;
        *)
            #unhandled
            return 9
            ;;
    esac
}
