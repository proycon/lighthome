#!/usr/bin/env sh
. "$HAROOT/scripts/common/include.sh"

havedep curl
havevar ETH008_IP
havevar ETH008_USER
havevar ETH008_PASSWORD

if [ -n "$1" ]; then
    curl --user $ETH008_USER:$ETH008_PASSWORD "http://$ETH008_IP/io.cgi?relay=$1"
else
    curl --user $ETH008_USER:$ETH008_PASSWORD "http://$ETH008_IP/io.cgi"
fi
