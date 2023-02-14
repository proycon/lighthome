#!/bin/sh

if [ -z "$HAROOT" ]; then
    echo "HAROOT not set">&2
    exit 2
fi
. "$HAROOT/scripts/common/include.sh"

havedep nfc-daemon

#shellcheck disable=SC2086
nfc-daemon | while read -r line
do
    if echo "$line" | grep -q UID; then
        UID="$(echo "$line" | sed 's/UID=//')"
        info "nfc IN: $UID"
        mqttpub "home/nfc" "$UID"
    fi
done
RET=$?

exit $RET
