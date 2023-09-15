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
    ~/lighthome/send.sh home/say/$(hostname) "Hans is away"
fi
if [ $MAARTEN -eq 0 ]; then
    ~/lighthome/send.sh home/say/$(hostname) "Maarten is away"
fi
if grep -qi ON /tmp/homestatus/binary_sensor/*; then
    ~/lighthome/send.sh home/say/$(hostname) "there are doors or windows open"
fi
~/lighthome/send.sh home/say/$(hostname) "central heating: $(cat /tmp/homestatus/climate/cv)"
~/lighthome/send.sh home/say/$(hostname) "climate control downstairs: $(cat /tmp/homestatus/climate/aircobeneden)"
~/lighthome/send.sh home/say/$(hostname) "climate control upstairs: $(cat /tmp/homestatus/climate/aircoboven)"
