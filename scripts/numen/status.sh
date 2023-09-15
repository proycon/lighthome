#!/bin/sh
HANS=0
MAARTEN=0
touch $NUMEN_STATE_DIR/acted
if [ "$(cat /tmp/homestatus/presence/hans)" = "ON" ]; then
    HANS=1
fi
if [ "$(cat /tmp/homestatus/presence/proycon)" = "ON" ]; then
    MAARTEN=1
fi
if [ $HANS -eq 0 ]; then
    run ~/lighthome/send.sh home/say/$(hostname) "Hans is away"
fi
if [ $MAARTEN -eq 0 ]; then
    run ~/lighthome/send.sh home/say/$(hostname) "Maarten is away"
fi
if grep -q ON /tmp/homestatus/binary_sensor/*; then
    run ~/lighthome/send.sh home/say/$(hostname) "there are doors or windows open"
fi
