#!/bin/sh

#main server script (in lxc container)

[ -n "$HAROOT" ] && export HAROOT="/home/homeautomation/lighthome"
[ -n "$PULSE_HOST" ] && export PULSE_HOST=192.168.0.1
export PLAY="mpv -ao pulse --pulse-host=$PULSE_HOST--no-video --really-quiet"

. "$HAROOT/scripts/common/include.sh"

settrap #kill all children when dying

#runs asynchronously
mqtt_receiver sound tts statefiles

mqtt_transmitter "CUSTOM" 0 nfc #transmits to home/nfc

mqttpub "home/command/ping" "$HOSTNAME" &

#wait for all processes to end
wait
