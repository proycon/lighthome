#!/bin/sh
PHRASES=~/lighthome/config/house.phrases
echo "load $PHRASES"
./send.sh home/say/$(hostname) "At your service" >/dev/null 2>/dev/null
