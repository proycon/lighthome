#!/bin/sh

#take care to run everything asynchronously from this point onward!

havevar HOSTNAME
havedep yt-dlp
havedep playerctl #MPRIS

[ -z "$PLAYVIDEO" ] && PLAYVIDEO="cvlc --play-and-exit"
havedep "$(echo "$PLAYVIDEO" | cut -d " " -f 1)"


clearqueue() {
    playerctl stop
    killall "$(echo "$PLAYVIDEO" | cut -d " " -f 1)"
    mkdir "$TMPDIR/videoqueue/"
    rm "$TMPDIR/videoqueue/"*
}

download() {
    mkdir -p "$TMPDIR/videoqueue/"
    cd "$TMPDIR/videoqueue/" || error "videoqueue not created"
    "$HAROOT/scripts/voice/picotts.sh" "Downloading video" &
    yt-dlp "$PAYLOAD" || (sleep 3 && "$HAROOT/scripts/voice/picotts.sh" "Download failed")
}

playqueue() {
    $PLAYVIDEO "$TMPDIR/videoqueue/"* || "$HAROOT/scripts/voice/picotts.sh" "Video playback failed"
}

handle_video() {
    case $TOPIC in
        "home/video/$HOSTNAME/clear")
            clearqueue
            return 0
            ;;
        "home/video/$HOSTNAME/pause")
            playerctl play-pause &
            return 0
            ;;
        "home/video/$HOSTNAME/stop")
            playerctl stop && clearqueue
            return 0
            ;;
        "home/video/$HOSTNAME/next")
            playerctl next
            return 0
            ;;
        "home/video/$HOSTNAME/forward")
            playerctl position 30+
            return 0
            ;;
        "home/video/$HOSTNAME/rewind")
            playerctl position 30-
            return 0
            ;;
        "home/video/$HOSTNAME/previous")
            playerctl previous
            return 0
            ;;
        "home/video/$HOSTNAME/loop")
            playerctl loop Track && "$HAROOT/scripts/voice/picotts.sh" "Loop enabled" &
            return 0
            ;;
        "home/video/$HOSTNAME/noloop")
            playerctl loop None && "$HAROOT/scripts/voice/picotts.sh" "Loop disabled" &
            return 0
            ;;
        "home/video/$HOSTNAME/add")
            case $PAYLOAD in
                http*)
                    download "$PAYLOAD" &
                    ;;
            esac
            ;;
        "home/video/$HOSTNAME/play")
            case $PAYLOAD in
                "")
                    "$HAROOT/scripts/voice/picotts.sh" "Playing existing video queue" &
                    playqueue &
                    ;;
                http*)
                    clearqueue
                    (download "$PAYLOAD" && playqueue) &
                    ;;
                *mp4|*avi|*webm|*ogv)
                    FILENAME="$HAROOT/media/$PAYLOAD"
                    if [ -e "$FILENAME" ]; then
                        $PLAY "$FILENAME" &
                    else
                        "$HAROOT/scripts/voice/picotts.sh" "Video file not found" &
                        error "Unable to play $FILENAME, file not found"
                    fi
                    return 0
                    ;;
                *)
                    "$HAROOT/scripts/voice/picotts.sh" "Unknown video" &
                    error "Unknown video payload"
                    ;;
            esac
            ;;
        *)
            return 9
            ;;
    esac
}
