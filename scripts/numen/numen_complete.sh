#!/bin/sh
if [ -e "$NUMEN_STATE_DIR/acted" ]; then
    rm "$NUMEN_STATE_DIR/acted"
    if [ -e "$NUMEN_STATE_DIR/listening" ]; then
        ~/lighthome/scripts/numen/numen_idle.sh
    fi
fi

