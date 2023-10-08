#!/bin/sh
PHRASES=~/lighthome/config/house.phrases
echo "load $PHRASES"
touch "$NUMEN_STATE_DIR/listening"
./send.sh home/say/$(hostname) "yes?" >/dev/null 2>/dev/null
pkill -10 -f startnumen.sh #this triggers (asynchronosuly) a few seconds wait and reversal to the idle state
#      ^-- SIGUSR1
