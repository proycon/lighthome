#!/bin/sh

if [ -z "$HAROOT" ]; then
    echo "HAROOT not set">&2
    exit 2
fi
. "$HAROOT/scripts/common/include.sh"

havedep nfc-daemon
NFCDAEMON=$(which nfc-daemon)

#uses a specificial sudoers rule to run nfc-daemon with sufficient privileges to access USB
# homeautomation ALL=(root) NOPASSWD: /usr/local/bin/nfc-daemon

#shellcheck disable=SC2086
sleep 5 #delay to prevent Unable to write to USB error when reconnecting rapidly
sudo -n "$NFCDAEMON" | tee /tmp/nfc.log | while read -r line
do
    if echo "$line" | grep -q UID; then
        UID="$(echo "$line" | sed 's/UID=//')"
        info "nfc IN: $UID"
        mqttpub "home/nfc" "$UID"
    fi
done
RET=$?

exit $RET
