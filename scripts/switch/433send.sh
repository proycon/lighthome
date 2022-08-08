#!/bin/sh
if [ -z "$HAROOT" ]; then
    echo "$HAROOT not set">&2
    exit 2
fi
. "$HAROOT/scripts/common/include.sh"
if [ $# -ne 5 ]; then
    echo "Requiring five arguments!" >&2
    exit 2
fi
COUNT=0
#prevent interference with other instances if launched asynchronously
while [ -f /tmp/43392.lock ]; do
    COUNT=$((COUNT+1))
    sleep 1
    if [ $COUNT -gt 12 ]; then
        #timeout
        break
    fi
done
touch /tmp/43392.lock
echo "Calling 433send $1 $2 $3 $4 $5" >&2
"$HAROOT/programs/433send/433send" "$1" "$2" "$3" "$4" "$5"
RET=$?
rm /tmp/43392.lock
exit $RET
