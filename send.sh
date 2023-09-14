#!/bin/sh

export HAROOT=~/lighthome

. "$HAROOT/scripts/common/include.sh"

NOTIFY=0
if [ "$1" = "--notify" ]; then
    shift
    NOTIFY=1
fi

mqttpub "$@"
ret=$?
if [ $NOTIFY -eq 1 ]; then
    if [ $ret -eq 0 ]; then
        $PLAY ~/lighthome/media/computerbeep_5.wav
    else
        $PLAY ~/lighthome/media/computerbeep_9.wav
    fi
fi
exit $ret
