#!/bin/sh
killall speech
killall numen

HOST=$(hostname)
if [ "$HOST" = "pi1" ]; then
    export PLAY="mpv --audio-device=alsa/sysdefault:CARD=Device --no-video --really-quiet"
fi

timeout() {
    echo "starting timeout countdown" && sleep 7 && ~/lighthome/scripts/numen/numen_idle.sh --silent | numenc && echo "back to idle mode"
}

cancel_timeout() {
    echo "cancelling timeout" && pkill -g 0 sleep && echo "cancelled timeout"
}

trap "timeout" USR1
trap "cancel_timeout" USR2

export MQTT_SESSION_SUFFIX=.send
./send.sh home/say/$(hostname) "At your service"
numen --phraselog=/dev/stdout ~/lighthome/config/house.idle.phrases &
while : ; do
    wait $! && exit 0
done
