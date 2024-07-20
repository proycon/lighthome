#!/bin/sh

if [ -z "$HAROOT" ]; then
    export HAROOT="$(dirname $(realpath "$0"))"
fi
export PLAY="timeout --kill-after=12s --signal=9 10s mpv computerbeep_5.wav"

. "$HAROOT/scripts/common/include.sh"

settrap #kill all children when dying

#runs asynchronously
mqtt_receiver sound tts notify statefiles

(sleep 2 && mqttpub "home/command/ping" "$HOSTNAME" && mqttpub "home/command/status" "$HOSTNAME") &

#wait for all processes to end
wait
