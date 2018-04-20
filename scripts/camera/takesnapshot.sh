#!/bin/bash

source /home/homeautomation/homeassistant/scripts/secrets.sh
cd /home/homeautomation/homeassistant/snapshots/
LOGDIR=/home/homeautomation/homeassistant/logs/

DATE=`date +%Y-%m-%d_%H:%M:%S`

MODE=$1
if [ -z "$MODE" ]; then
    echo "No mode set!" >&2
    exit 2
fi

if [ -f "$MODE.lock" ]; then
    exit 1
else
    touch "$MODE.lock"
fi

FLIP=0
if [ ! -z "$2" ]; then
    if [[ "$2" == "ON" ]] || [[ "$2" == "on" ]] || [[ "$2" == "true" ]]; then
        FLIP=1
    fi
fi

if [ "$MODE" == "frontdoor" ]; then
    fswebcam -S 3 -r 640x480 -d $FRONTDOORCAM_DEV --save $DATE.$MODE.jpg 2>$LOGDIR/camera.$MODE.log
elif [ "$MODE" == "hallupstairs" ]; then
    fswebcam -S 3 -r 640x480 -d $HALLUPSTAIRSCAM_DEV --save $DATE.$MODE.jpg 2>$LOGDIR/camera.$MODE.log
elif [ "$MODE" == "livingroom" ]; then
    curl -sS --netrc-file $LIVINGROOMCAM_NETRC http://$LIVINGROOMCAM_IP/image/jpeg.cgi -o tmp.jpg 2>$LOGDIR/camera.$MODE.log
    if [ $FLIP -eq 1 ]; then
        convert -flip -flop tmp.jpg $DATE.$MODE.jpg
    else
        mv tmp.jpg $DATE.$MODE.jpg
    fi
elif [ "$MODE" == "street" ]; then
    curl -sS "http://$STREETCAM_IP:88/cgi-bin/CGIProxy.fcgi?cmd=snapPicture2&usr=$STREETCAM_USER&pwd=$STREETCAM_PASSWORD" -o $DATE.$MODE.jpg 2>$LOGDIR/camera.$MODE.log
elif [ "$MODE" == "oldstreet" ]; then
    curl -sS "http://$OLDSTREETCAM_IP/snapshot.cgi?user=$STREETCAM_USER&pwd=$STREETCAM_PASSWORD" -o $DATE.$MODE.jpg 2>$LOGDIR/camera.$MODE.log
elif [ "$MODE" == "garden" ]; then
    curl -sS "http://$GARDENCAM_IP/snapshot.cgi?user=$GARDENCAM_USER&pwd=$GARDENCAM_PASSWORD" -o $DATE.$MODE.jpg 2>$LOGDIR/camera.$MODE.log
else
    rm "$MODE.lock"
    echo "No such mode: $MODE" >&2
    exit 2
fi

rm "$MODE.lock"

if [ -f $DATE.$MODE.jpg ]; then
    ln -sf $DATE.$MODE.jpg _$MODE.jpg
else
    echo "Failed to take a snapshot for $MODE" >&2
    exit 3
fi

exit 0
