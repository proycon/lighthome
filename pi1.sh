#!/bin/sh

export HAROOT="/home/homeautomation/lighthome"

. "$HAROOT/scripts/common/include.sh"

settrap #kill all children when dying

export GPIO_PIN_433SEND=4
export SNAPCAST_SOUNDCARD=36

#runs asynchronously
mqtt_receiver 433send sound musicplayer tts kodi hdmi_cec_send statefiles

export GPIO_PIN=25
export GPIO_INVERT=1
export GPIO_PULL=down
mqtt_transmitter "home/binary_sensor/frontdoor" 0 gpio

export GPIO_PIN=21
export GPIO_INVERT=1
export GPIO_PULL=down
mqtt_transmitter "home/binary_sensor/doorbell" 0 gpio

#wait for all processes to end
wait
