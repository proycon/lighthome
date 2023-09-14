#!/bin/sh
PHRASES=~/lighthome/config/house.idle.phrases
echo "load $PHRASES"
./send.sh home/say/$(hostname) "Bye" >/dev/null 2>/dev/null
