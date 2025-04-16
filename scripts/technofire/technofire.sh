#!/bin/sh
if [ -z "$HAROOT" ]; then
    echo "HAROOT not set">&2
    exit 2
fi
. "$HAROOT/scripts/common/include.sh"

havedep pkill
havedep "$HAROOT/scripts/technofire/technofire.py"

if [ "$SUDO_TECHNOFIRE" = "1" ]; then
    sudo pkill -f technofire.py > /dev/null 2>/dev/null
    sudo $HAROOT/scripts/technofire/technofire.py $@
else
    pkill -f technofire.py > /dev/null 2>/dev/null
    $HAROOT/scripts/technofire/technofire.py $@
fi
