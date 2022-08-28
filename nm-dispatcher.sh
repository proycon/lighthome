#!/bin/sh

#NetworkManager dispatcher

if [ -z "$HAROOT" ]; then
    export HAROOT="$(dirname $(realpath "$0"))"
fi
. "$HAROOT/scripts/common/include.sh"

PLAY=play
IFACE=$1
ACTION=$2
[ -n "$ACTION" ] || die "no action received"
[ -n "$PLAY" ] || die "play not defined"

case $ACTION in
    up)
        $PLAY $HAROOT/media/connect.wav
        mqttpub "home/command/ping" "$HOSTNAME"
        ;;
    down)
        $PLAY $HAROOT/media/disconnect.wav
        ;;
    *)
        echo "Not handling $ACTION" >&2
        ;;
esac
