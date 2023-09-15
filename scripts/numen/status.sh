#!/bin/sh
HANS=0
MAARTEN=0
~/lighthome/scripts/numen/numen_idle.sh | numenc
#touch $NUMEN_STATE_DIR/acted
if [ "$(cat /tmp/homestatus/presence/hans)" = "ON" ]; then
    HANS=1
fi
if [ "$(cat /tmp/homestatus/presence/proycon)" = "ON" ]; then
    MAARTEN=1
fi
if [ $HANS -eq 0 ]; then
    ~/lighthome/send.sh home/say/$(hostname) "Hans is away"
    sleep 3
fi
if [ $MAARTEN -eq 0 ]; then
    ~/lighthome/send.sh home/say/$(hostname) "Maarten is away"
    sleep 3
fi
if grep -qi ON /tmp/homestatus/binary_sensor/*; then
    ~/lighthome/send.sh home/say/$(hostname) "there are doors or windows open"
    sleep 4
fi
~/lighthome/send.sh home/say/$(hostname) "central heating: $(cat /tmp/homestatus/climate/cv)"
sleep 4
~/lighthome/send.sh home/say/$(hostname) "climate control downstairs: $(cat /tmp/homestatus/climate/aircobeneden)"
sleep 4
~/lighthome/send.sh home/say/$(hostname) "climate control upstairs: $(cat /tmp/homestatus/climate/aircoboven)"
sleep 4
