#!/bin/sh
phrase=$(cat "$NUMEN_STATE_DIR/phrase")
if [ "$phrase" != "house listen" ]; then
    ~/lighthome/scripts/numen/numen_idle.sh
fi

