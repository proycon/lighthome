#!/bin/sh
if [ -z "$HAROOT" ]; then
    echo "$HAROOT not set">&2
    exit 2
fi
. "$HAROOT/scripts/common/include.sh"

havedep pkill
havedpe "$HAROOT/scripts/technofire/technofire.py"

pkill -f technofire.py > /dev/null 2>/dev/null
$HAROOT/scripts/technofire/technofire.py $@
