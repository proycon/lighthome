#!/bin/sh

#take care to run everything asynchronously from this point onward!

havevar MPD_HOST
havedep mpc

handle_mpc() {
    case $TOPIC in
        "home/command/music/load")
            info "mpc: Loading playlist $PAYLOAD"
            (mpc clear && mpc playlist load "$PAYLOAD" && mpc play) &
            return 0
            ;;
        "home/command/music/search/filename")
            info "mpc: Searching filename $PAYLOAD"
            (mpc clear && mpc search filename "$PAYLOAD" && mpc play) &
            return 0
            ;;
        "home/command/music/search/artist")
            info "mpc: Searching artist $PAYLOAD"
            (mpc clear && mpc search artist "$PAYLOAD" && mpc play) &
            return 0
            ;;
        "home/command/music/search/title")
            info "mpc: Searching title $PAYLOAD"
            (mpc clear && mpc search title "$PAYLOAD" && mpc play) &
            return 0
            ;;
        "home/command/music/search/genre")
            info "mpc: Searching genre $PAYLOAD"
            (mpc clear && mpc search genre "$PAYLOAD" && mpc play) &
            return 0
            ;;
        "home/command/music/next")
            info "mpc: next"
            mpc next &
            return 0
            ;;
        "home/command/music/previous")
            info "mpc: prev"
            mpc prev &
            return 0
            ;;
        "home/command/music/clear")
            info "mpc: clear"
            mpc clear &
            return 0
            ;;
        "home/command/music/pause")
            info "mpc: pause"
            mpc pause &
            return 0
            ;;
        "home/command/music/play")
            info "mpc: play"
            mpc play &
            return 0
            ;;
        *)
            #unhandled
            return 9
            ;;
    esac
}
