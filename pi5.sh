#!/bin/sh

export HAROOT="/home/homeautomation/lighthome"

. "$HAROOT/scripts/common/include.sh"

settrap #kill all children when dying

#runs asynchronously, calls specified handlers
mqtt_receiver technofire

wait #wait for all children
