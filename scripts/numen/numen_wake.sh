#!/bin/sh
PHRASES=~/lighthome/config/house.phrases
echo "load $PHRASES"
./send.sh home/say/$(hostname) "yes?" >/dev/null 2>/dev/null
#if [ -n "$1" ]; then
#    (sleep $1; ~/lighthome/scripts/numen/numen_idle.sh --silent) &
#fi
