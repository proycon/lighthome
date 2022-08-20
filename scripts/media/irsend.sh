#!/bin/sh
echo "Running: irsend SEND_ONCE $1 $2">&2
irsend SEND_ONCE "$1" "$2"
