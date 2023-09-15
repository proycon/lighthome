#!/bin/sh
PHRASES=~/lighthome/config/house.idle.phrases
echo "load $PHRASES"
rm "$NUMEN_STATE_DIR/listening" 2>/dev/null
if [ "$1" != "--silent" ]; then
    ./send.sh home/say/$(hostname) "Done" >/dev/null 2>/dev/null
fi
