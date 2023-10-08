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
    trap "sleep 7 && ~/lighthome/scripts/numen/numen_idle.sh --silent" USR1
    trap "pkill -g 0 sleep" USR2
) &

export MQTT_SESSION_SUFFIX=.send
./send.sh home/say/$(hostname) "At your service"
numen --phraselog=/dev/stdout ~/lighthome/config/house.idle.phrases
./send.sh home/say/$(hostname) "Stopped listening"
