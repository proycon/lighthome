#!/bin/sh


if [ -z "$HAROOT" ]; then
    echo "HAROOT not set">&2
    exit 2
fi
. "$HAROOT/scripts/common/include.sh"

havedep rflinkproxy
havedep nc

[ -n "$RFLINK_DEVICE" ] || RFLINK_DEVICE=/dev/ttyACM0
[ -n "$RFLINK_PORT" ] ||  RFLINK_PORT=1770
killall rflinkproxy 2>/dev/null #there can be only one
info "rflink: starting background daemon: rflinkproxy --port $RFLINK_DEVICE --listenport $RFLINK_PORT"
rflinkproxy --port $RFLINK_DEVICE --listenport $RFLINK_PORT &
PID=$!

sleep 10
info "rflink: attaching to daemon"
pgrep rflinkproxy || die "rflinkproxy didn't init correctly"

getswitchcmd() {
    SWITCH="$(echo "$PAYLOAD" | cut -d";" -f 1 | sed 's/SWITCH=//')"
    CMD="$(echo "$PAYLOAD" | cut -d";" -f 2 | sed 's/CMD=//')"
}

#shellcheck disable=SC2086
nc localhost $RFLINK_PORT | while read -r line
do
    VENDOR="$(echo "$line" | cut -d";" -f 3)"
    ID="$(echo "$line" | cut -d";" -f 4 | sed 's/ID=//')"
    DEVICE="${VENDOR}_${ID}"
    PAYLOAD="$(echo "$line" | cut -d";" -f 5-)"
    info "rflink IN: $DEVICE $PAYLOAD"
    case "$DEVICE" in
        Xiron_4C01)
            #weersensor op balkon bij insectenhotel   (zwarte receiver unit boven)
            info "rflink: handling $DEVICE"
            TEMP="$(echo "$PAYLOAD" | cut -d";" -f 1 | sed 's/TEMP=//')"
            TEMP=$(printf '%d\n' 0x$TEMP) #hex to decimal
            TEMP=$(echo "scale=1; $TEMP / 10" | bc -l)
            HUM="$(echo "$PAYLOAD" | cut -d";" -f 2 | sed 's/HUM=//')"
            mqttpub "home/sensor/outside_temperature" "$TEMP"
            mqttpub "home/sensor/outside_humidity" "$HUM"
            ;;
        LacrosseV4_0009)
            #Sensor in kasje tegen buitenmuur
            info "rflink: handling $DEVICE"
            TEMP="$(echo "$PAYLOAD" | cut -d";" -f 1 | sed 's/TEMP=//')"
            TEMP=$(printf '%d\n' 0x$TEMP) #hex to decimal
            TEMP=$(echo "scale=1; $TEMP / 10" | bc -l)
            mqttpub "home/sensor/greenhouse_temperature" "$TEMP"
            ;;
        TriState_0008aa|TriState_000a2a|TriState_0002a8|TriState_0000aa*|Kaku_000041|NewKaku_00000079|NewKaku_00000078|TriState_00022a|AB400D_44|AB400D_60|Kaku_4d)
            #feedback from own lights: office light, hall, backroom, back corner, balcony, midspots...
            getswitchcmd #not used any further 
            info "rflink: feedback from own lights ($DEVICE)"
            ;;
        *)
            info "rflink: unhandled ($DEVICE)"
            ;;
    esac
done
RET=$?

kill $PID
exit $RET
