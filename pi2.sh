#!/bin/sh

export HAROOT="/home/homeautomation/lighthome"

. "$HAROOT/scripts/common/include.sh"

settrap #kill all children when dying

export DEVICE_CEC=/dev/cec0

export GPIO_PIN_433SEND=23
export SNAPCAST_SOUNDCARD=17
export ONEWIRE_DEVICE_ID=28-0000059319c4

export GPIO25_TOPIC="home/binary_sensor/backdoor"
export GPIO25_INVERT=1
export GPIO25_PULL=down
export GPIO17_TOPIC="home/binary_sensor/bedroomwindow_right"
export GPIO17_INVERT=1
export GPIO17_PULL=down
export GPIO22_TOPIC="home/binary_sensor/bedroomwindow_left"
export GPIO22_INVERT=1
export GPIO22_PULL=down

export MPD_HOST="192.168.0.1"
export DEFAULT_MPC_SEARCH="Instrumental/Calm Piano"

export SUDO_TECHNOFIRE=1

#runs asynchronously, calls specified handlers
mqtt_receiver 433send sound video musicplayer tts kodi technofire irsend hdmi_cec_send statefiles desktop

#runs asynchronously, calls specified sender
#         TOPIC
#         POLL-INTERVAL (seconds, 0=one-run)
#         SENDER
mqtt_transmitter "home/sensor/bedroom_temperature" 60 onewire 

export GPIO_PIN=25
export GPIO_INVERT=1
export GPIO_PULL=down
mqtt_transmitter "home/binary_sensor/backdoor" 0 gpio

export GPIO_PIN=17
export GPIO_INVERT=1
export GPIO_PULL=down
mqtt_transmitter "home/binary_sensor/bedroomwindow_right" 0 gpio


export GPIO_PIN=22
export GPIO_INVERT=1
export GPIO_PULL=down
mqtt_transmitter "home/binary_sensor/bedroomwindow_left" 0 gpio

#mqtt_transmitter "CUSTOM" 0 rflink

wait #wait for all children
