#!/bin/sh
PHRASES=~/lighthome/config/house.idle.phrases
echo "load $PHRASES"
if [ "$1" != "--silent" ]; then
    ./send.sh home/say/$(hostname) "Ok" >/dev/null 2>/dev/null
fi
