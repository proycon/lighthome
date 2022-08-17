#!/bin/sh

if [ -z "$HAROOT" ]; then
    echo "HAROOT not set">&2
    exit 2
fi
. "$HAROOT/scripts/common/include.sh"

havedep "rflink"

#shellcheck disable=SC2086
stdbuf --output=0 "$(which rflink)" | tr -s " " | while read -r line
do
    DEVICE="$(echo "$line" | cut -f 1)"
    PAYLOAD="$(echo "$line" | cut -f 2)"
    info "rflink: $DEVICE $PAYLOAD"
    case "$DEVICE" in
        xiron_4c01_temp)
            #op balkon bij insectenhotel   (zwarte receiver unit boven)
            mqttpub "home/weatherstation/temp" "$PAYLOAD"
            ;;
        xiron_4c01_hum)
            #op balkon bij insectenhotel  (zwarte receiver unit boven)
            mqttpub "home/weatherstation/hum" "$PAYLOAD"
            ;;
        lacrossev4_0009_temp)
            #greenhouse
            mqttpub "home/greenhouse/temp" "$PAYLOAD"
            ;;
        tristate_0008aa*|tristate_000a2a*|tristate_0002a8*|tristate_0000aa*|kaku_000041*|newkaku_00000079*|newkaku_00000078*|tristate_00022a*)
            #feedback from own lights: office light, hall, backroom, back corner, balcony, midspots...
            info "rflink feedback from own lights ($DEVICE)"
            ;;
        *)
            info "rflink unhandled ($DEVICE)"
            ;;
    esac
done
