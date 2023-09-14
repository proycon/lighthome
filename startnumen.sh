#!/bin/sh
killall speech
killall numen

HOST=$(hostname)
if [ "$HOST" = "pi1" ]; then
    export PLAY="mpv --audio-device=alsa/sysdefault:CARD=Device --no-video --really-quiet"
fi

export MQTT_SESSION_SUFFIX=.send
./send.sh home/say/pi1 "Voice control enabled"
numen --phraselog=/dev/stdout ~/lighthome/config/house.phrases
./send.sh home/say/pi1 "Voice control disabled"
