#!/bin/sh

if [ -z "$HAROOT" ]; then
    echo "HAROOT not set">&2
    exit 2
fi
. "$HAROOT/scripts/common/include.sh"

havevar "$GPIO_PIN"
havedep "$HAROOT/programs/gpio_binary_sensor"

case "$GPIO_PULL" in
    down|DOWN)
        OPTS="-d"
        ;;
    up|UP)
        OPTS="-u"
        ;;
esac

[ -z "$PAYLOAD_ON" ] && PAYLOAD_ON=ON
[ -z "$PAYLOAD_OFF" ] && PAYLOAD_OFF=OFF

#shellcheck disable=SC2086
"$HAROOT/programs/gpio_binary_sensor" $OPTS -p $GPIO_PIN | while read -r line
do
    case "$line" in
        0)
            if [ "$GPIO_INVERT" -eq 0 ]; then
                echo $PAYLOAD_OFF
            else
                echo $PAYLOAD_ON
            fi
            ;;
        1)
            if [ "$GPIO_INVERT" -eq 0 ]; then
                echo $PAYLOAD_ON
            else
                echo $PAYLOAD_OFF
            fi
            ;;
    esac
done
