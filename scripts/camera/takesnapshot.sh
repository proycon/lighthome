#!/bin/sh

if [ -z "$HAROOT" ]; then
    echo "HAROOT not set">&2
    exit 2
fi
. "$HAROOT/scripts/common/include.sh"

havedep curl

cd /home/homeautomation/snapshots/ || die "Snapshot dir not found"
LOGDIR=/home/homeautomation/logs/
mkdir -p "$LOGDIR"

DATE=$(date +%Y-%m-%d_%H:%M:%S)

MODE=$1
if [ -z "$MODE" ]; then
    echo "No mode set!" >&2
    exit 2
fi

if [ -e "$TMPDIR/$MODE.lock" ]; then
    exit 1
else
    touch "$TMPDIR/$MODE.lock"
fi

FLIP=0
if [ -n "$2" ]; then
    if [ "$2" = "ON" ] || [ "$2" = "on" ] || [ "$2" = "true" ]; then
        FLIP=1
    fi
fi

if [ "$MODE" = "livingroom" ]; then
    curl -sS "http://$LIVINGROOMCAM_IP:88/cgi-bin/CGIProxy.fcgi?cmd=snapPicture2&usr=$LIVINGROOMCAM_USER&pwd=$LIVINGROOMCAM_PASSWORD" -o tmp.jpg 2>"$LOGDIR/camera.$MODE.log"
    #curl -sS --netrc-file $LIVINGROOMCAM_NETRC http://$LIVINGROOMCAM_IP/image/jpeg.cgi -o tmp.jpg 2>$LOGDIR/camera.$MODE.log
    if [ $FLIP -eq 1 ]; then
        convert -flip -flop tmp.jpg "$DATE.$MODE.jpg"
    else
        mv tmp.jpg "$DATE.$MODE.jpg"
    fi
elif [ "$MODE" = "street" ]; then
    curl -sS "http://$STREETCAM_USER:$STREETCAM_PASSWORD@$STREETCAM_IP/Streaming/Channels/1/picture" -o "$DATE.$MODE.jpg" 2>"$LOGDIR/camera.$MODE.log"
elif [ "$MODE" = "balcony" ]; then
    curl -sS "http://$BALCONYCAM_IP:88/cgi-bin/CGIProxy.fcgi?cmd=snapPicture2&usr=$BALCONYCAM_USER&pwd=$BALCONYCAM_PASSWORD" -o "$DATE.$MODE.jpg" 2>"$LOGDIR/camera.$MODE.log"
elif [ "$MODE" = "garden" ]; then
    curl -sS "http://$GARDENCAM_IP/snapshot.cgi?user=$GARDENCAM_USER&pwd=$GARDENCAM_PASSWORD" -o "$DATE.$MODE.jpg" 2>"$LOGDIR/camera.$MODE.log"
elif [ "$MODE" = "frontdoor" ]; then
    #unused
    fswebcam -S 3 -r 640x480 -d "$FRONTDOORCAM_DEV" --save "$DATE.$MODE.jpg" 2>"$LOGDIR/camera.$MODE.log"
elif [ "$MODE" = "hallupstairs" ]; then
    #unused
    fswebcam -S 3 -r 640x480 -d "$HALLUPSTAIRSCAM_DEV" --save "$DATE.$MODE.jpg" 2>"$LOGDIR/camera.$MODE.log"
else
    rm "$TMPDIR/$MODE.lock"
    echo "No such mode: $MODE" >&2
    exit 2
fi

rm "$TMPDIR/$MODE.lock"

if [ -f "$DATE.$MODE.jpg" ]; then
    ln -sf "$DATE.$MODE.jpg" "_$MODE.jpg"
else
    echo "Failed to take a snapshot for $MODE" >&2
    exit 3
fi

exit 0
