#!/bin/sh
PHRASES=~/lighthome/config/house.phrases
echo "load $PHRASES"
./send.sh home/say/$(hostname) "yes?" >/dev/null 2>/dev/null
