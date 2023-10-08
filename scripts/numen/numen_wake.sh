#!/bin/sh
PHRASES=~/lighthome/config/house.phrases
echo "load $PHRASES"
touch "$NUMEN_STATE_DIR/listening"
./send.sh home/say/$(hostname) "yes?" >/dev/null 2>/dev/null
#pkill -f numen_idle.sh 2> /dev/null
#(sleep 7 && ~/lighthome/scripts/numen/numen_idle.sh --silent) &
