#!/bin/sh

#main server script (in lxc container)

export HAROOT="/home/homeautomation/lighthome"
export PLAY="mpv -ao pulse --pulse-host=10.252.116.1 --no-video --really-quiet"

. "$HAROOT/scripts/common/include.sh"

settrap #kill all children when dying

#runs asynchronously
mqtt_receiver sound tts statefiles

mqtt_transmitter "CUSTOM" 0 nfc #transmits to home/nfc

mqttpub "home/command/ping" "$HOSTNAME" &

#wait for all processes to end
wait
