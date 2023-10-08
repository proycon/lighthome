#!/bin/sh
killall speech
killall numen

HOST=$(hostname)
if [ "$HOST" = "pi1" ]; then
    export PLAY="mpv --audio-device=alsa/sysdefault:CARD=Device --no-video --really-quiet"
fi

trap "" USR1
trap "" USR2
(
    EXIT=0
    trap "sleep 7 && ~/lighthome/scripts/numen/numen_idle.sh --silent" USR1
    trap "pkill -g 0 sleep" USR2
    trap "EXIT=1 && pkill -g 0 sleep" TERM
    while $EXIT -ne 1; do
        sleep 10000
    done
) &

export MQTT_SESSION_SUFFIX=.send
./send.sh home/say/$(hostname) "At your service"
numen --phraselog=/dev/stdout ~/lighthome/config/house.idle.phrases
./send.sh home/say/$(hostname) "Stopped listening"
