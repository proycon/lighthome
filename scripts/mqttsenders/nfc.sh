#!/bin/sh

if [ -z "$HAROOT" ]; then
    echo "HAROOT not set">&2
    exit 2
fi
. "$HAROOT/scripts/common/include.sh"

havedep nfc-daemon
NFCDAEMON=$(which nfc-daemon)

#uses a specificial udev rule to run nfc-daemon with sufficient privileges to access USB
# ATTRS{idVendor}=="072f", ATTRS{idProduct}=="2200", SUBSYSTEMS=="usb", ACTION=="add", MODE="0666", GROUP="plugdev"

#shellcheck disable=SC2086
sleep 5 #delay to prevent Unable to write to USB error when reconnecting rapidly
info "nfc starting daemon"
"$NFCDAEMON" | while read -r line
do
    if echo "$line" | grep -q UID; then
        UID="$(echo "$line" | sed 's/UID=//')"
        info "nfc IN: $UID"
        mqttpub "home/nfc" "$UID"
    elif [ -n "$line" ]; then
        info "nfc (unhandled): $line"
    fi
done
RET=$?
info "nfc daemon stopped"

exit $RET
