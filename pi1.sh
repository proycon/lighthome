#!/bin/sh

export HAROOT="/home/homeautomation/lighthome"
export PLAY="mpv --audio-device=alsa/sysdefault:CARD=Device --no-video --really-quiet"
export MEDIAPATH="/Server/proycon/ /Server/anaxotic/"

. "$HAROOT/scripts/common/include.sh"

settrap #kill all children when dying

export DEVICE_CEC=/dev/cec0

export GPIO_PIN_433SEND=4
export SNAPCAST_SOUNDCARD="hdmi:CARD=vc4hdmi0"
export MPD_HOST="192.168.0.1"
export DEFAULT_MPC_SEARCH="Instrumental/Calm Piano"

#runs asynchronously
mqtt_receiver 433send sound video musicplayer tts kodi irsend hdmi_cec_send statefiles desktop

export GPIO_PIN=25
export GPIO_INVERT=1
export GPIO_PULL=down
mqtt_transmitter "home/binary_sensor/frontdoor" 0 gpio

export GPIO_PIN=21
export GPIO_INVERT=0
export GPIO_PULL=down
mqtt_transmitter "home/binary_sensor/doorbell" 0 gpio

mqttpub "home/command/ping" "$HOSTNAME" &

#wait for all processes to end
wait
