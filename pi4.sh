#!/bin/sh

export HAROOT="/home/homeautomation/lighthome"

. "$HAROOT/scripts/common/include.sh"

settrap #kill all children when dying

#runs asynchronously, calls specified handlers
mqtt_receiver technofire


export GPIO_PIN_DHT22=4
export DHT22_MODE=c
mqtt_transmitter "home/sensor/temperature_attic" 60 dht22

export GPIO_PIN_DHT22=4
export DHT22_MODE=h
mqtt_transmitter "home/sensor/humidity_attic" 360 dht22

mqttpub "home/command/ping" "$HOSTNAME" &

wait #wait for all children
